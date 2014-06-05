class WelcomeController < ApplicationController
	def index
		if current_user
			redirect_to dashboard_path
		else
			@page = Page.find_by sort_index: SortIndex::WELCOME
		end
	end
end
