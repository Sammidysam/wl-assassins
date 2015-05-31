class DashboardController < ApplicationController
	def index
		unless current_user
			redirect_to log_in_path, alert: "You must log in to view your dashboard!"
		else
			if current_user.admin?
				games = Game.all
				@unpaid_games = games.select { |game| game.started_at && game.prize_money < game.expected_money }
				@pregames = games.select { |game| !game.in_progress && !game.completed? }
				@ongoing_games = games.where in_progress: true
			else
				@team = current_user.team
				@invitations = current_user.memberships.where(started_at: nil)
			end

			# Variables passed to the switch_user_select partial.
			if Rails.env.development? && current_user
				select_users = User.where.not(id: current_user.id).order(:name)
				@user_names = select_users.map(&:name)
			end
		end
	end

	def switch_user
		# First ensure the right people are doing this.
		if current_user && (current_user.admin? || session[:previous_user_id]) && Rails.env.development?
			unless session[:previous_user_id]
				user = User.find_by name: params[:user_name]

				session[:previous_user_id] = session[:user_id]
				session[:user_id] = user.id
			else
				session[:user_id] = session[:previous_user_id]
				session.delete(:previous_user_id)
			end

			redirect_to dashboard_path, notice: "You have switched user to user of id #{session[:user_id]}!"
		else
			redirect_to dashboard_path, alert: "You are not authorized to switch user!"
		end
	end
end
