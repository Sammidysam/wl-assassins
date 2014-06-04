class WelcomeController < ApplicationController
	def index
		if view_context.current_user
			redirect_to dashboard_path
		else
			# The welcome page has a special sort index of 0.
			@page = Page.find_by sort_index: 0
		end
	end
end
