module Revival
	extend ActiveSupport::Concern

	def revive_user(user)
		eliminated = user.team.eliminated?
		out_of_town = user.team.out_of_town?
		
		# Destroy all confirmed kills on the user.
		user.kills.where(game_id: user.team.participation.game_id, confirmed: true).destroy_all

		# Add autotermination job for user.
		user.autoterminate

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
		end

		if !out_of_town && user.team.out_of_town?
			# Kill all members of the team.
			user.team.alive_members.each do |member|
				kill = Kill.new
				kill.target_id = member.id
				kill.kind = "out_of_town"
				kill.game_id = user.team.participation.game_id
				kill.appear_at = (24 - user.team.participation.out_of_town_hours).hours.from_now

				kill.save
			end
		elsif out_of_town && !user.team.out_of_town?
			# Get old kills.
			kills = Kill.out_of_town.where(target_id: user.team.members.map { |member| member.id }, game_id: user.team.participation.game_id).where.not(appear_at: nil)
			
			# Adjust out_of_town_hours.
			participation = user.team.participation

			participation.out_of_town_hours += TimeDifference.between(kills.first.created_at, Time.now).in_hours

			participation.save

			# Delete old kills if out_of_town_hours is less than 24.
			kills.destroy_all if participation.out_of_town_hours < 24
		end
	end
end
