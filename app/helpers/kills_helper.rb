module KillsHelper
	def default_killer_id(kind, game, target_team_id)
		case kind
		when "assassination"
			if current_user.admin?
				game.remaining_teams.count > 4 ? game.remaining_teams.find { |t| t.target.id == target_team_id }.id : nil
			else
				current_user.team.id
			end
		when "termination"
			participation = Participation.find_by(game_id: game.id, terminators: true)

			(current_user.team && current_user.team.terminators?) ? current_user.team.id : (participation ? participation.team_id : nil)
		end
	end
end
