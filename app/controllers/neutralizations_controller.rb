class NeutralizationsController < ApplicationController
	before_action :set_neutralization, only: [:show, :edit, :update, :destroy, :confirm]
	
	load_and_authorize_resource

	# GET /neutralizations
	# GET /neutralizations.json
	def index
		@neutralizations = Neutralization.all.select { |neutralization| can? :read, neutralization }
	end

	# GET /neutralizations/1
	# GET /neutralizations/1.json
	def show
	end

	# GET /neutralizations/new
	def new
		@neutralization = Neutralization.new

		if params[:email]
			@neutralizer = User.find_by(email: params[:email])
		else
			redirect_to root_path, alert: "You are not authorized to access this page."
		end

		unless performed?
			@neutralization.killer_id = current_user.id
			@neutralization.target_id = @neutralizer.id
			@neutralization.game_id = @neutralizer.team.participation.game_id
		end
	end

	# GET /neutralizations/1/edit
	def edit
	end

	# POST /neutralizations
	def create
		@neutralization = Neutralization.new(neutralization_params)

		if @neutralization.save
			redirect_to root_path, notice: "Successfully reported neutralization!"
		else
			redirect_to root_path, alert: "Could not create neutralization!"
		end
	end

	# PATCH/PUT /neutralizations/1
	# PATCH/PUT /neutralizations/1.json
	def update
		respond_to do |format|
			if @neutralization.update(neutralization_params)
				format.html { redirect_to @neutralization, notice: "Neutralization was successfully updated." }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @neutralization.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /neutralizations/1
	def destroy
		redirect_to root_path, alert: (@neutralization.destroy ? nil : "Could not destroy neutralization!")
	end

	# POST /neutralizations/1/confirm
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
