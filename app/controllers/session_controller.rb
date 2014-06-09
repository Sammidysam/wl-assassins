class SessionController < ApplicationController
	def new
		redirect_to root_path if current_user
	end

	def create
		@user = User.find_by email: params["email"]
		
		if @user && @user.authenticate(params["password"])
			session[:user_id] = @user.id

			redirect_to root_path
		else
			redirect_to log_in_path, alert: "Failed to log in!"
		end
	end

	def destroy
		session[:user_id] = nil

		redirect_to root_path
	end
end
