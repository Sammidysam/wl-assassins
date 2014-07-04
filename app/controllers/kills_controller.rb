class KillsController < ApplicationController
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
			@kill.target_id = @target.id
			@kill.kind = @kind if @kind
			@kill.game_id = @target.team.participation.game_id
			@kill.killer_id = view_context.default_killer_id(@kind, @target.team.participation.game_id)
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
			redirect_to root_path, alert: "Could not create kill!"
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
			# Remove autotermination for dead user.
			kill.target.remove_autotermination

			# Remove out-of-town kills for dead user.
			kill.target.remove_out_of_town_kills
			
			# Reset termination_at for killing team.
			if kill.assassination?
				participation = kill.killer.participation

				# First remove old autotermination kills.
				participation.team.remove_autotermination
				
				participation.termination_at = kill.confirmed_at + (kill.game.remaining_teams.count > 4 ? 5 : 4).days
				
				participation.save

				# Create new autotermination job.
				participation.team.autoterminate
			end

			# Account for if the team is now eliminated.
			if kill.target.team.eliminated? && !already_eliminated
				# Close current contract.
				old_contract = killer_team_contract

				old_contract.completed = true
				old_contract.end = kill.confirmed_at

				old_contract.save

				unless kill.game.remaining_teams.count == 1
					# Create and assign new contract.
					new_contract = Contract.new
					new_contract.participation_id = killer_team.participation.id
					new_contract.target_id = target_contract.target_id
					new_contract.start = kill.confirmed_at

					new_contract.save

					# Do special action for two remaining teams.
					if kill.game.remaining_teams.count == 2
						# Reset both termination times.
						kill.game.remaining_teams.each do |team|
							participation = team.participation

							participation.termination_at = kill.confirmed_at + 4.days

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
