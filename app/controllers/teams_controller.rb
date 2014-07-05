class TeamsController < ApplicationController
	include Revival
	
	before_action :set_team, only: [:show, :edit, :update, :destroy, :add, :remove, :terminators, :revive, :reset_termination_at, :reset_out_of_town_hours]

	load_and_authorize_resource

	# GET /teams
	# GET /teams.json
	def index
		@teams = Team.select { |team| can? :read, team }
	end

	# GET /teams/1
	# GET /teams/1.json
	def show
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
					membership.active = true
					membership.user_id = current_user.id
					membership.team_id = @team.id
					
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
		respond_to do |format|
			if @team.update(team_params)
				format.html { redirect_to @team, notice: "Team was successfully updated." }
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
		unless user = User.find_by("lower(email) = ?", params[:email].downcase)
			redirect_to @team, alert: "#{params[:email]} does not have an account!"
		else
			membership = Membership.new
			membership.active = true
			membership.user_id = user.id
			membership.team_id = @team.id

			redirect_to @team, alert: (membership.save ? nil : "Could not join team!")
		end
	end

	# POST /teams/1/remove
	def remove
		membership = @team.memberships.find { |inner_membership| inner_membership.user.email == params[:email] && inner_membership.active }
		membership.active = false

		redirect_to (current_user.email == params[:email] ? root_path : @team), alert: (membership.save ? nil : "Could not remove from team!")
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

		participation.termination_at = (@team.participation.game.teams.select { |team| !team.terminators? && !team.eliminated? }.count > 4 ? 5 : 4).days.from_now

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
