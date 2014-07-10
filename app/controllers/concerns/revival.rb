module Revival
	extend ActiveSupport::Concern

	def revive_user(user)
		eliminated = user.team.eliminated?
		out_of_town = user.team.out_of_town?
		
		# Destroy all confirmed kills on the user.
		user.kills.where(game_id: user.team.participation.game_id, confirmed: true).destroy_all

		# Then revive the team if necessary.
		if eliminated
			# Destroy the old contract to eliminate this team.
			Contract.where(target_id: user.team.id, completed: true).find { |contract| contract.participation.game_id == user.team.participation.game_id }.destroy

			teams = view_context.contract_order_teams(user.team.participation.game, user.team.contract.next_non_eliminated_target)

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

			# Reset termination_at for team.
			participation = user.team.participation

			participation.termination_at = (participation.game.teams.select { |team| !team.terminators? && !team.eliminated? }.count > 4 ? 5 : 4).days.from_now

			participation.save
		end

		# Add autotermination job for user.
		user.autoterminate

		if !out_of_town && user.team.out_of_town?
			user.team.out_of_town_kill
		elsif out_of_town && !user.team.out_of_town?
			# Get old kills.
			kills = Kill.out_of_town.where(target_id: user.team.members.map { |member| member.id }, game_id: user.team.participation.game_id).where.not(appear_at: nil)
			
			# Adjust out_of_town_hours.
			participation = user.team.participation

			participation.out_of_town_hours += (Time.now - kills.first.created_at) / 1.hour

			participation.save

			# Delete old kills if out_of_town_hours is less than 24.
			kills.destroy_all if participation.out_of_town_hours < 24
		end
	end
end
