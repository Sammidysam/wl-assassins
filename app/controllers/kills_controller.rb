class KillsController < ApplicationController
	before_action :set_kill, only: [:destroy, :confirm]
	
	load_and_authorize_resource
	
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
	end

	def create
		@kill = Kill.new(kill_params)

		if @kill.save
			redirect_to root_path, notice: "Successfully created kill!"
		else
			redirect_to root_path, alert: "Could not create kill!"
		end
	end

	def destroy
		redirect_to root_path, alert: (@kill.destroy ? nil : "Could not destroy kill!")
	end

	def confirm
		@already_eliminated = @kill.target.team.eliminated?
		unless @already_eliminated
			@killer_team = @kill.assassination? ? @kill.killer : @kill.game.remaining_teams.find { |team| team.contract.target_id == @kill.target.team.id }
			@killer_team_contract = @killer_team.contract
			@target_contract = @kill.target.team.contract
		end
		
		@kill.confirmed = true
		@kill.confirmed_at = DateTime.now

		if @kill.save
			# Reset termination_at for killing team.
			if @kill.assassination?
				participation = @kill.killer.participation

				# First remove old autotermination kills.
				participation.team.remove_autotermination
				
				participation.termination_at = @kill.confirmed_at + (@kill.game.remaining_teams.count > 4 ? 5 : 4).days
				
				participation.save

				# Create new autotermination job.
				participation.team.autoterminate
			end

			# Account for if the team is now eliminated.
			if @kill.target.team.eliminated? && !@already_eliminated
				# Close current contract.
				old_contract = @killer_team_contract

				old_contract.completed = true
				old_contract.end = @kill.confirmed_at

				old_contract.save

				unless @kill.game.remaining_teams.count == 1
					# Create and assign new contract.
					new_contract = Contract.new
					new_contract.participation_id = @killer_team.participation.id
					new_contract.target_id = @target_contract.target_id
					new_contract.start = @kill.confirmed_at

					new_contract.save

					# Do special action for two remaining teams.
					if @kill.game.remaining_teams.count == 2
						# Reset both termination times.
						@kill.game.remaining_teams.each do |team|
							participation = team.participation

							participation.termination_at = @kill.confirmed_at + 4.days

							participation.save
						end
					end
				else
					# Delete autotermination job for winner team.
					@killer_team.remove_autotermination
					
					# Close up game.
					game = @kill.game

					game.in_progress = false
					game.ended_at = @kill.confirmed_at

					game.save
				end
			end

			# Account for if the remaining members of the team are out-of-town.
			if @kill.target.team.alive_members.all? { |member| member.out_of_town }
				@kill.target.team.alive_members.each do |member|
					kill = Kill.new
					kill.target_id = member.id
					kill.kind = "out_of_town"
					kill.game_id = @kill.game_id

					kill.save
				end
			end

			redirect_to root_path
		else
			redirect_to root_path, alert: "Could not confirm kill!"
		end
	end

	private
	def set_kill
		@kill = Kill.find(params[:id])
	end
	
	def kill_params
		params.require(:kill).permit(:confirmed, :target_id, :picture_url, :how, :kind, :game_id, :killer_id)
	end
end
