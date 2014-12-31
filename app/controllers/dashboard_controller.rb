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

			# Variables passed to the switch_user_select partial.
			if Rails.env.development? && current_user
				select_users = User.where.not(id: current_user.id)
				@user_names = select_users.map(&:name)
			end
		end
	end

	def switch_user
		# First ensure the right people are doing this.
		if current_user && current_user.admin? && Rails.env.development?
			user = User.find_by name: params[:user_name]

			session[:previous_user_id] = session[:user_id]
			session[:user_id] = user.id

			redirect_to dashboard_path, notice: "You have switched user to #{params[:user_name]}!"
		else
			redirect_to dashboard_path, alert: "You are not authorized to switch user!"
		end
	end
end
