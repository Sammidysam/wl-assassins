module KillsHelper
	def default_killer_id(kind, game_id)
		case kind
		when "assassination"
			current_user.team.id
		when "termination"
			participation = Participation.find_by(game_id: game_id, terminators: true)
			
			(current_user.team && current_user.team.terminators?) ? current_user.team.id : (participation ? participation.team_id : nil)
		end
	end
end
