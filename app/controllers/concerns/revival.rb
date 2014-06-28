module Revival
	extend ActiveSupport::Concern

	def revive_user(user)
		eliminated = user.team.eliminated?
		
		# Destroy all confirmed kills on the user.
		user.kills.where(game_id: user.team.participation.game_id, confirmed: true).destroy_all

		# Then revive the team if necessary.
		if eliminated
			# Get the old contract to eliminate this team.
			old_contract = Contract.where(target_id: user.team.id, completed: true).find { |contract| contract.participation.game_id == user.team.participation.game_id }

			# Destroy the new contract for the killing team.
			old_contract.participation.team.contract.destroy

			old_contract.completed = false
			old_contract.end = nil

			old_contract.save
		end
	end
end
