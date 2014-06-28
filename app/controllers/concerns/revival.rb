module Revival
	extend ActiveSupport::Concern

	def revive_user(user)
		eliminated = user.team.eliminated?
		
		# Destroy all confirmed kills on the user.
		user.kills.where(game_id: user.team.participation.game_id, confirmed: true).destroy_all

		# Then revive the team if necessary.
		if eliminated
			# Destroy the old contract to eliminate this team.
			Contract.where(target_id: user.team.id, completed: true).find { |contract| contract.participation.game_id == user.team.participation.game_id }.destroy

			teams = view_context.contract_order_teams(user.team.participation.game)

			# Insert current team into last slot of contract order teams.
			# Adjust last team's contract to be targeted at current team.
			killer_contract = teams.last.contract

			killer_contract.target_id = user.team.id

			killer_contract.save

			# Create contract for current team.
			# Delete current contract.
			user.team.contract.destroy

			# Create new contract.
			contract = Contract.new
			contract.participation_id = user.team.participation.id
			contract.target_id = teams.first.id
			contract.start = DateTime.now

			contract.save
		end
	end
end
