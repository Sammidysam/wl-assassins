class DashboardController < ApplicationController
	def index
		unless current_user
			redirect_to log_in_path, alert: "You must log in to view your dashboard!"
		else
			# Admin variables.
			games = Game.all
			@unpaid_games = games.select { |game| game.prize_money < game.expected_money }
			@pregames = games.select { |game| !game.in_progress && !game.completed? }
			@ongoing_games = games.where in_progress: true

			# Normal user variables.
			@team = current_user.team
		end
	end
end
