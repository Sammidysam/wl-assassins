class WelcomeController < ApplicationController
	def index
		redirect_to(dashboard_path) if view_context.current_user

		@page = Page.find_by welcome: true
	end
end
