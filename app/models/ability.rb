class Ability
	include CanCan::Ability
	include DistanceOfTimeInWords

	def initialize(user)
		logged_in = true if user

		# If user is not logged in, make them be a guest user.
		user ||= User.new

		can :create, User
		can :index, User

		can :read, User.all do |can_user|
			can_user.public_admin?
		end

		can :read, Team.all do |team|
			team.eliminated? || team.disbanded? || !team.in_game?
		end

		can :index, Team if Team.all.select { |team| can? :read, team }.count > 0

		can :day, Page
		can :read, Page

		can :read, Game.all do |game|
			game.in_progress? || game.completed?
		end

		can :index, Game
		can :events, Game

		cannot :monitor, Game

		can :index, Kill

		can :read, Kill.all do |kill|
			kill.confirmed
		end

		can :index, Neutralization

		can :read, Neutralization.all do |neutralization|
			neutralization.confirmed
		end

		if logged_in
			can :manage, Team.all do |team|
				team.members.include? user
			end

			cannot :add, Team if user.team && user.team.in_game?
			cannot :remove, Team if user.team && user.team.in_game?

			cannot :revive, Team

			if user.team && user.team.contract
				contract = user.team.contract
				if contract.is_a?(Contract) && contract.target
					can :read, Team.all do |team|
						contract.target_id == team.id
					end
				else
					contract.each do |c|
						can :read, Team.all do |team|
							c.target_id == team.id
						end
					end
				end
			end

			if user.terminator?
				can :read, Team.all do |team|
					team.in_game? && user.team.participation.game_id == team.participation.game_id && !team.terminators? && precise_distance_of_time_in_words_to_now(team.participation.termination_at, interval: :day) == 0 && user.team.participation.game.remaining_teams.count > 2
				end
			end

			can :create, Team if !user.team && user.eligible?
			can :index, Team if user.team

			if user.team
				can :read, User.all do |can_user|
					user.team.members.include? can_user
				end
			end

			if user.team && user.team.contract
				contract = user.team.contract
				if contract.is_a?(Contract) && contract.target
					can :read, User.all do |can_user|
						contract.target.members.include? can_user
					end
				else
					contract.each do |c|
						can :read, User.all do |can_user|
							c.target.members.include? can_user
						end
					end
				end
			end

			if user.terminator?
				can :read, User.all do |can_user|
					can_user.team && can_user.team.in_game? && user.team.participation.game_id == can_user.team.participation.game_id && !can_user.terminator? && precise_distance_of_time_in_words_to_now(can_user.team.participation.termination_at, interval: :day) == 0 && user.team.participation.game.remaining_teams.count > 2
				end
			end

			can :index, User

			can :manage, user

			cannot :revive, user

			can :create, Kill if user.alive? && !user.neutralized?

			can :confirm, Kill.all do |kill|
				user.id == kill.target_id
			end

			can :update, Kill.all do |kill|
				kill.killer.members.map { |member| member.id }.include?(user.id) && kill.confirmed if kill.killer
			end

			can :respond, Membership.all do |membership|
				membership.started_at.nil? && membership.user_id == user.id && user.eligible?
			end

			can :create, Neutralization if user.alive? && !user.neutralized?

			can :confirm, Neutralization.all do |neutralization|
				user.id == neutralization.target_id
			end

			can :update, Neutralization.all do |neutralization|
				user.id == neutralization.killer_id && neutralization.confirmed
			end
		end

		cannot :destroy, :all

		can :manage, :all if user.admin?

		cannot [:read, :update, :confirm], Kill.all do |kill|
			!kill.appear_at.nil? && kill.appear_at > DateTime.now
		end
	end
end
