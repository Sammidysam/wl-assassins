class DashboardController < ApplicationController
	def index
		unless current_user
			redirect_to log_in_path, alert: "You must log in to view your dashboard!"
		else
			# Admin variables.
			@pregames = Game.where(in_progress: false).select { |game| !game.completed? }
			@ongoing_games = Game.where in_progress: true

			# Normal user variables.
			@team = current_user.team
		end
	end
end
