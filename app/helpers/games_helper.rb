module GamesHelper
	# Returns the non-eliminated teams in the game game in order of contracts.
	def contract_order_teams(game)
		teams = []
		starter_team = game.teams.select { |team| !team.eliminated? }.first

		teams << starter_team

		while (next_team = next_team ? next_team.contract.target : starter_team.contract.target).id != starter_team.id
			teams << next_team
		end

		teams
	end
end
