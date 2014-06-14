class KillsController < ApplicationController
	load_and_authorize_resource
	
	def new
		@kill = Kill.new

		if params[:email]
			@target = User.find_by(email: params[:email])
		else
			redirect_to root_path, alert: "You are not authorized to access this page."
		end

		@kind = params[:kind] if params[:kind]
	end

	def create
		@kill = Kill.new(kill_params)

		redirect_to root_path, alert: (@kill.save ? nil : "Could not create kill!")
	end

	def destroy
		@kill = Kill.find(params[:id])

		redirect_to root_path, alert: (@kill.destroy ? nil : "Could not destroy kill!")
	end

	private
	def kill_params
		params.require(:kill).permit(:participation_id, :target_id, :picture_url, :how, :kind)
	end
end
