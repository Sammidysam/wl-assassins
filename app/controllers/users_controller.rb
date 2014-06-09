class UsersController < ApplicationController
	before_action :set_user, only: [:show, :edit, :update, :destroy, :out_of_town]

	load_and_authorize_resource

	# GET /users
	# GET /users.json
	def index
		@users = User.all.select { |user| can? :read, user }
	end

	# GET /users/1
	# GET /users/1.json
	def show
	end

	# GET /users/new
	def new
		@user = User.new
	end

	# GET /users/1/edit
	def edit
	end

	# POST /users
	# POST /users.json
	def create
		@user = User.new(user_params)

		respond_to do |format|
			if @user.save
				format.html { redirect_to @user, notice: 'User was successfully created.' }
				format.json { render action: 'show', status: :created, location: @user }
			else
				format.html { render action: 'new' }
				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /users/1
	# PATCH/PUT /users/1.json
	def update
		respond_to do |format|
			if @user.update(user_params)
				format.html { redirect_to @user, notice: 'User was successfully updated.' }
				format.json { head :no_content }
			else
				format.html { render action: 'edit' }
				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /users/1
	# DELETE /users/1.json
	def destroy
		# Log out before destroying the user if the user is logged in.
		session[:user_id] = nil if session[:user_id] == @user.id
		
		@user.destroy
		
		respond_to do |format|
			format.html { redirect_to users_url }
			format.json { head :no_content }
		end
	end

	# POST /users/1/out_of_town
	# Toggles the out_of_town boolean in @user.
	def out_of_town
		@user.toggle :out_of_town

		redirect_to dashboard_path, alert: (@user.save ? nil : "Could not toggle out-of-town!")
	end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_user
		@user = User.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation, :phone_number, :phone_number_public, :address, :address_public, :graduation_year, :description, :profile_picture_url, :out_of_town, :willing_to_pay_amount)
	end
end
