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
		@kill.confirmed = true

		if @kill.save
			# Reset termination_at for killing team.
			if @kill.kind == "assassination"
				participation = @kill.killer.participation
				
				participation.termination_at = DateTime.now + (@kill.game.teams.select { |team| !team.terminators? && !team.eliminated? }.count > 4 ? 5 : 4).days
				participation.save
			end

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
		params.require(:kill).permit(:confirmed, :target_id, :picture_url, :how, :kind, :game_id, :killer_id)
	end
end
