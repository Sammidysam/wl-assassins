class WelcomeController < ApplicationController
	def index
		redirect_to(dashboard_path) if view_context.current_user

		@page = Page.where("name LIKE ?", "welcome").first
	end
end
