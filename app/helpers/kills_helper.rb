module KillsHelper
	def default_participation_id(kind, game_id)
		case kind
		when "assassination"
			current_user.team.participation.id
		when "termination"
			participation = Participation.find_by(game_id: game_id, terminators: true)
			
			(current_user.team && current_user.team.terminators?) ? current_user.team.participation.id : (participation ? participation.id : nil)
		else
			nil
		end
	end
end
