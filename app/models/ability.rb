class Ability
	include CanCan::Ability

	def initialize(user)
		logged_in = true if user
		
		# If user is not logged in, make them be a guest user.
		user ||= User.new

		can :create, User
		can :index, User

		can :read, User.all do |can_user|
			can_user.public_admin?
		end

		can :day, Page
		can :read, Page

		can :read, Game.all do |game|
			game.completed?
		end

		can :index, Game
		can :events, Game

		if logged_in
			can :manage, Team.all do |team|
				team.members.include? user
			end

			cannot :remove, Team if user.team && user.team.in_game?
			
			cannot :revive, Team

			if user.team && user.team.contract && user.team.contract.target
				can :read, Team.all do |team|
					user.team.contract.target_id == team.id
				end
			end

			if user.terminator?
				can :read, Team.all do |team|
					team.in_game? && user.team.participation.game_id == team.participation.game_id && !team.terminators? && team.remaining_kill_time.in_days.floor == 0 && user.team.participation.game.remaining_teams.count > 2
				end
			end
			
			can :create, Team unless user.team
			can :index, Team if user.team

			if user.team
				can :read, User.all do |can_user|
					user.team.members.include? can_user
				end
			end

			if user.team && user.team.contract && user.team.contract.target
				can :read, User.all do |can_user|
					user.team.contract.target.members.include? can_user
				end
			end

			if user.terminator?
				can :read, User.all do |can_user|
					can_user.team && can_user.team.in_game? && user.team.participation.game_id == can_user.team.participation.game_id && !can_user.terminator? && can_user.team.remaining_kill_time.in_days.floor == 0 && user.team.participation.game.remaining_teams.count > 2
				end
			end

			can :index, User
			
			can :manage, user

			cannot :revive, user

			can :create, Kill if user.alive? && !user.neutralized?

			can :confirm, Kill.all do |kill|
				user.id == kill.target_id && (kill.appear_at.nil? || kill.appear_at < DateTime.now)
			end

			can :create, Neutralization if user.alive? && !user.neutralized?

			can :confirm, Neutralization.all do |neutralization|
				user.id == neutralization.target_id
			end
		end

		cannot :destroy, :all

		can :manage, :all if user.admin?
	end
end
