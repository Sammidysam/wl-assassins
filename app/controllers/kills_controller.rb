class KillsController < ApplicationController
	include DistanceOfTimeInWords
	include TerminationAt

	before_action :set_kill, only: [:show, :edit, :update, :destroy, :confirm]

	load_and_authorize_resource

	# GET /kills
	# GET /kills.json
	def index
		@kills = Kill.all.select { |kill| can? :read, kill }
	end

	# GET /kills/1
	# GET /kills/1.json
	def show
	end

	# GET /kills/new
	def new
		@kill = Kill.new

		if params[:email]
			@target = User.find_by(email: params[:email])
		else
			redirect_to root_path, alert: "You are not authorized to access this page."
		end

		@kind = params[:kind] || "assassination"

		if @kind != "assassination" && !current_user.admin?
			redirect_to root_path, alert: "You are not allowed to create a kill of this kind!" unless @kind == "termination" && current_user.terminator?
		end

		unless performed?
			target_team_participation_game = @target.team.participation.game
			@kill.target_id = @target.id
			@kill.kind = @kind if @kind
			@kill.game_id = target_team_participation_game.id
			@kill.killer_id = view_context.default_killer_id(@kind, target_team_participation_game, @target.team.id)

			@terminators = Team.where(id: target_team_participation_game.participations.where(terminators: true).map(&:team_id))
		end
	end

	# GET /kills/1/edit
	def edit
	end

	# POST /kills
	def create
		@kill = Kill.new(kill_params)

		if @kill.save
			if current_user.admin?
				if confirm_kill(@kill)
					redirect_to root_path, notice: "Successfully reported and confirmed kill!"
				else
					redirect_to root_path, alert: "The kill was created, but it could not be confirmed."
				end
			else
				redirect_to root_path, notice: "Successfully reported kill!"
			end
		else
			redirect_to root_path, alert: "Could not create kill!  #{@kill.errors.full_messages.first}."
		end
	end

	# PATCH/PUT /kills/1
	# PATCH/PUT /kills/1.json
	def update
		respond_to do |format|
			if @kill.update(kill_params)
				format.html { redirect_to @kill, notice: "Kill was successfully updated." }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @kill.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /kills/1
	def destroy
		redirect_to root_path, alert: (@kill.destroy ? nil : "Could not destroy kill!")
	end

	# POST /kills/1/confirm
	def confirm
		if confirm_kill(@kill)
			redirect_to root_path, notice: "Successfully confirmed kill!"
		else
			redirect_to root_path, alert: "Could not confirm kill!"
		end
	end

	private
	def set_kill
		@kill = Kill.find(params[:id])
	end

	def kill_params
		params.require(:kill).permit(:target_id, :picture_url, :how, :kind, :game_id, :killer_id)
	end

	def confirm_kill(kill)
		already_eliminated = kill.target.team.eliminated?
		unless already_eliminated
			killer_team = kill.assassination? ? kill.killer : kill.game.remaining_teams.find { |team| team.contract.target_id == kill.target.team.id }
			killer_team_contract = killer_team.contract
			target_contract = kill.target.team.contract
		end
		already_out_of_town = kill.target.team.out_of_town?

		kill.confirmed = true
		kill.confirmed_at = DateTime.now

		if kill.save
			# Remove autotermination for dead team.
			kill.target.remove_autotermination

			# Remove out-of-town kills for dead team.
			kill.target.remove_out_of_town_kills

			# Reset termination_at for killing team.
			if kill.assassination? && kill.game.remaining_teams.count > 4
				participation = kill.killer.participation

				# First remove old autotermination kills.
				participation.team.remove_autotermination

				participation.termination_at = next_termination_at(kill.game.remaining_teams.count)

				participation.save

				# Create new autotermination job.
				participation.team.autoterminate
			end

			# Account for if the team is now eliminated.
			if kill.target.team.eliminated? && !already_eliminated
				# Give the team an extra day to make the kill if they are low on time.
				participation = killer_team.participation

				if precise_distance_of_time_in_words_to_now(participation.termination_at, interval: :day) == 0 && kill.game.remaining_teams.count > 4
					participation.team.remove_autotermination
					participation.termination_at += 1.day
					participation.save
					participation.team.autoterminate
				end

				# Close current contract.
				old_contract = killer_team_contract

				old_contract.completed = true
				old_contract.end = kill.confirmed_at

				old_contract.save

				unless kill.game.remaining_teams.count == 1
					# Create and assign new contract.
					if kill.game.remaining_teams.count > 4
						new_contract = Contract.new
						new_contract.participation_id = killer_team.participation.id
						new_contract.target_id = target_contract.target_id
						new_contract.start = kill.confirmed_at

						new_contract.save
					elsif kill.game.remaining_teams.count == 4
						# Everybody needs to now be contracted to kill everyone else.
						kill.game.remaining_teams.each do |team|
							current_target = team.contract.target_id if team.contract
							kill.game.remaining_teams.each do |inner_team|
								next if team.id == inner_team.id || current_target == inner_team.id

								contract = Contract.new
								contract.participation_id = team.participation
								contract.target_id = inner_team.id
								contract.start = kill.confirmed_at

								contract.save
							end
						end
					end

					# Reset termination times when necessary.
					if [2, 4].include?(kill.game.remaining_teams.count)
						kill.game.remaining_teams.each do |team|
							participation = team.participation

							participation.termination_at = next_termination_at(kill.game.remaining_teams.count)

							participation.save
						end
					end
				else
					# Delete autotermination job for winner team.
					killer_team.remove_autotermination

					# Close up game.
					game = kill.game

					game.in_progress = false
					game.ended_at = kill.confirmed_at

					game.save

					# Now place the teams.
					game.place_teams
				end
			end

			# Account for if the remaining members of the team are out-of-town.
			if !already_out_of_town && kill.target.team.out_of_town?
				kill.target.team.alive_members.each do |member|
					out_of_town_kill = Kill.new
					out_of_town_kill.target_id = member.id
					out_of_town_kill.kind = "out_of_town"
					out_of_town_kill.game_id = kill.game_id
					out_of_town_kill.appear_at = (24 - kill.target.team.participation.out_of_town_hours).hours.from_now

					out_of_town_kill.save
				end
			end

			true
		else
			false
		end
	end
end
