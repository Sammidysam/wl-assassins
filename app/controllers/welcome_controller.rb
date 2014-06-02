class WelcomeController < ApplicationController
	def index
		redirect_to(dashboard_path) if view_context.current_user
	end
end
