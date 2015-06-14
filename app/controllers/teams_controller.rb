class TeamsController < ApplicationController
	include Revival
	include TerminationAt

	before_action :set_team, only: [:show, :edit, :update, :destroy, :add, :remove, :terminators, :revive, :reset_termination_at, :reset_out_of_town_hours, :paid_amount]

	load_and_authorize_resource

	# GET /teams
	# GET /teams.json
	def index
		@teams = Team.order(:name).select { |team| can? :read, team }
	end

	# GET /teams/1
	# GET /teams/1.json
	def show
		# People available to add to a team.
		normal_users = User.normal.order(:name)
		@users = normal_users.select { |u| !u.team }

		@changes = @team.name_changes

		# n+1
		@participations = @team.participations.order(:created_at).select { |p| p.game.completed? }
		@games = Game.where(id: @participations.map(&:game_id))
	end

	# GET /teams/new
	def new
		@team = Team.new
	end

	# GET /teams/1/edit
	def edit
	end

	# POST /teams
	# POST /teams.json
	def create
		@team = Team.new(team_params)

		respond_to do |format|
			if @team.save
				format.html do
					# Add current user to team.
					membership = Membership.new
					membership.user_id = current_user.id
					membership.team_id = @team.id
					membership.started_at = DateTime.now

					redirect_to @team, notice: "Team was successfully created.", alert: (membership.save ? nil : "Could not join created team.")
				end
				format.json { render action: "show", status: :created, location: @team }
			else
				format.html { render action: "new" }
				format.json { render json: @team.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /teams/1
	# PATCH/PUT /teams/1.json
	def update
		old_name = @team.name

		respond_to do |format|
			if @team.update(team_params)
				error = false
				if @team.name != old_name
					change = NameChange.new
					change.team_id = @team.id
					change.from = old_name
					change.to = @team.name

					error = !change.save
				end

				format.html { redirect_to @team, notice: "Team was successfully updated.#{"  Could not make a name change." if error}" }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @team.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /teams/1
	# DELETE /teams/1.json
	def destroy
		@team.destroy
		respond_to do |format|
			format.html { redirect_to teams_url }
			format.json { head :no_content }
		end
	end

	# POST /teams/1/add
	def add
		unless user = User.find_by(id: params[:user_id])
			redirect_to @team, alert: "#{params[:user_id]} does not have an account!"
		else
			membership = Membership.new
			membership.user_id = user.id
			membership.team_id = @team.id

			membership.save ? flash[:notice] = "Invitation successfully sent!" : flash[:alert] = "Could not send an invitation to this person!  #{membership.errors.full_messages.first}."
			redirect_to @team
		end
	end

	# POST /teams/1/remove
	def remove
		membership = @team.memberships.find { |inner_membership| inner_membership.user.email == params[:email] && inner_membership.active? }

		redirect_to (current_user.email == params[:email] ? root_path : @team), alert: (membership.update_attribute(:ended_at, DateTime.now) ? nil : "Could not remove from team!")
	end

	# POST /teams/1/terminators
	def terminators
		participation = @team.participations.find_by(game_id: params[:game_id])

		participation.toggle :terminators

		redirect_to game_path(params[:game_id]), alert: (participation.save ? nil : "Could not toggle terminator status!")
	end

	# POST /teams/1/revive
	def revive
		@team.dead_members.each { |member| revive_user member }

		redirect_to @team.participation.game
	end

	# POST /teams/1/reset_termination_at
	def reset_termination_at
		participation = @team.participation

		@team.remove_autotermination

		participation.termination_at = next_termination_at(@team.participation.game.remaining_teams.count)

		participation.save

		@team.autoterminate

		redirect_to @team.participation.game
	end

	# POST /teams/1/reset_out_of_town_hours
	def reset_out_of_town_hours
		participation = @team.participation

		@team.remove_out_of_town_kills if @team.out_of_town?

		participation.out_of_town_hours = 0.0

		@team.out_of_town_kill if @team.out_of_town?

		redirect_to @team.participation.game, alert: (participation.save ? nil : "Could not reset out-of-town hours!")
	end

	# POST /teams/1/paid_amount
	def paid_amount
		participation = Participation.find(params[:participation_id])

		participation.paid_amount = params[:paid_amount]

		redirect_to team_fees_game_path(participation.game), alert: (participation.save ? nil : "Could not change paid amount!")
	end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_team
		@team = Team.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def team_params
		params.require(:team).permit(:name, :description, :logo_url)
	end
end
