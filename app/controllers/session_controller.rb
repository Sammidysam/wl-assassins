class SessionController < ApplicationController
	def new
		redirect_to(root_path) if view_context.current_user
	end

	def create
		@user = User.find_by email: params["email"]
		
		if @user && @user.authenticate(params["password"])
			session["current_user_id"] = @user.id

			redirect_to root_path
		else
			redirect_to session_new_path, alert: "Failed to log in!"
		end
	end

	def destroy
		session["current_user_id"] = nil

		redirect_to root_path
	end
end
