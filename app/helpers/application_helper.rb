module ApplicationHelper
	def current_user
		User.find(session[:user_id]) if session[:user_id]
	end

	def title(title_string)
		content_for :title, title_string.to_s
	end

	def markdown(content)
		Markdown::RENDERER.render(content).html_safe
	end

	def glyphicon(icon)
		content_tag :span, nil, class: "glyphicon glyphicon-#{icon}"
	end
	
	# Returns the non-eliminated teams in the game game in order of contracts.
	def contract_order_teams(game)
		teams = []
		starter_team = game.teams.select { |team| !team.terminators? && !team.eliminated? }.first

		if starter_team
			teams << starter_team

			while (next_team = next_team ? next_team.contract.target : starter_team.contract.target).id != starter_team.id
				teams << next_team
			end

			teams
		end
	end
end
