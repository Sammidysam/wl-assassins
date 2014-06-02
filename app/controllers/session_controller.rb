class SessionController < ApplicationController
	def new
		redirect_to root_path if current_user
	end

	def create
		fail_message = "Failed to log in!"

		users = User.where :email => params["email"]

		if users.count > 0
			@user = users.first

			if @user.authenticate params["password"]
				session["current_user_id"] = @user.id

				redirect_to root_path
			else
				redirect_to session_new_path, :alert => fail_message
			end
		else
			redirect_to session_new_path, :alert => fail_message
		end
	end

	def destroy
		session["current_user_id"] = nil

		redirect_to root_path
	end
end
