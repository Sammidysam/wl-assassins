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

	def link_to_if_can_read(name, link)
		can?(:read, link) ? link_to(name, link) : name
	end
	
	# Returns the non-eliminated teams in the game game in order of contracts.
	def contract_order_teams(game, starter_team = nil)
		teams = []
		starter_team ||= game.teams.select { |team| !team.terminators? && !team.eliminated? }.first

		if starter_team
			teams << starter_team

			while (next_team = next_team ? next_team.contract.target : starter_team.contract.target).id != starter_team.id
				teams << next_team
			end

			teams
		end
	end

	def precise_distance_of_time_in_words(from_time, to_time, no_time = false)
		return "no time" if no_time && from_time < to_time
		
		from_time = from_time.to_time if from_time.respond_to?(:to_time)
		to_time = to_time.to_time if to_time.respond_to?(:to_time)
		distance_in_seconds = ((to_time - from_time).abs).round
		components = []

		%w(year month week day hour minute).each do |interval|
			# For each interval type, if the amount of time remaining is greater than
			# one unit, calculate how many units fit into the remaining time.
			if distance_in_seconds >= 1.send(interval)
				delta = (distance_in_seconds / 1.send(interval)).floor
				distance_in_seconds -= delta.send(interval)
				components << pluralize(delta, interval)
			end
		end

		components.to_sentence
	end

	def precise_distance_of_time_in_words_to_now(from_time, no_time = false)
		precise_distance_of_time_in_words from_time, DateTime.now, no_time
	end
end
