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

		redirect_to root_path, alert: (@kill.save ? nil : "Could not confirm kill!")
	end

	private
	def set_kill
		@kill = Kill.find(params[:id])
	end
	
	def kill_params
		params.require(:kill).permit(:confirmed, :target_id, :picture_url, :how, :kind, :game_id, :killer_id)
	end
end
