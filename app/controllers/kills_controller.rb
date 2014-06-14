class KillsController < ApplicationController
	load_and_authorize_resource
	
	def new
	end

	def create
	end

	def destroy
		@kill = Kill.find(params[:id])

		redirect_to root_path, alert: (@kill.destroy ? nil : "Could not destroy kill!")
	end
end
