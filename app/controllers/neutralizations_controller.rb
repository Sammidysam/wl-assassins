class NeutralizationsController < ApplicationController
	load_and_authorize_resource
	
	def new
		@neutralization = Neutralization.new

		if params[:email]
			@neutralizer = User.find_by(email: params[:email])
		else
			redirect_to root_path, alert: "You are not authorized to access this page."
		end
	end

	def create
		@neutralization = Neutralization.new(neutralization_params)

		redirect_to root_path, alert: (@neutralization.save ? nil : "Could not create neutralization!")
	end

	def destroy
		@neutralization = Neutralization.find(params[:id])

		redirect_to root_path, alert: (neutralization.destroy ? nil : "Could not destroy neutralization!")
	end

	private
	def neutralization_params
		params.require(:neutralization).permit(:killer_id, :target_id, :game_id, :how, :picture_url)
	end
end
