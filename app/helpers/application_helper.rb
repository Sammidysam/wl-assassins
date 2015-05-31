module ApplicationHelper
	include DistanceOfTimeInWords

	def current_user
		if @current_user
			if @current_user.id == session[:user_id]
				@current_user
			else
				@current_user = session[:user_id] && User.find_by_id(session[:user_id])
			end
		else
			@current_user = session[:user_id] && User.find_by_id(session[:user_id])
		end
	end

	def title(title_string)
		content_for :title, title_string.to_s
	end

	def markdown(content)
		MarkdownTools::RENDERER.render(content).html_safe
	end

	def glyphicon(icon)
		content_tag :span, nil, class: "glyphicon glyphicon-#{icon}"
	end

	def link_to_if_can_read(name, link)
		can?(:read, link) ? link_to(name, link) : name
	end

	# Returns the non-eliminated teams in the game game in order of contracts.
	def contract_order_teams(game, starter_team = nil)
		teams = []
		starter_team ||= game.remaining_teams.first

		if starter_team
			teams << starter_team

			while (next_team = next_team ? next_team.contract.target : starter_team.contract.target).id != starter_team.id
				teams << next_team
			end

			teams
		end
	end
end
