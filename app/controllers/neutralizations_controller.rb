class NeutralizationsController < ApplicationController
	before_action :set_neutralization, only: [:destroy, :confirm]
	
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

		if @neutralization.save
			redirect_to root_path, notice: "Successfully created neutralization!"
		else
			redirect_to root_path, alert: "Could not create neutralization!"
		end
	end

	def destroy
		redirect_to root_path, alert: (@neutralization.destroy ? nil : "Could not destroy neutralization!")
	end

	def confirm
		@neutralization.confirmed = true
		@neutralization.start = DateTime.now

		redirect_to root_path, alert: (@neutralization.save ? nil : "Could not confirm neutralization!")
	end

	private
	def set_neutralization
		@neutralization = Neutralization.find(params[:id])
	end
	
	def neutralization_params
		params.require(:neutralization).permit(:killer_id, :target_id, :game_id, :how, :picture_url)
	end
end
