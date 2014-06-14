class NeutralizationsController < ApplicationController
	load_and_authorize_resource
	
	def new
		@target = User.find_by(email: params[:email])
	end

	def create
	end

	def destroy
		@neutralization = Neutralization.find(params[:id])

		redirect_to root_path, alert: (neutralization.destroy ? nil : "Could not destroy neutralization!")
	end
end
