class Ability
	include CanCan::Ability

	def initialize(user)
		logged_in = true if user
		
		# If user is not logged in, make them be a guest user.
		user ||= User.new

		can :create, User
		
		can :read, Page

		can :read, Game.all do |game|
			game.completed?
		end

		if logged_in
			can :manage, Team.all do |team|
				team.members.include? user
			end

			if user.team && user.team.contract.target
				can :read, Team.all do |team|
					user.team.contract.target_id == team.id
				end
			end

			if user.team
				can :read, User.all do |can_user|
					user.team.members.include? can_user
				end
			end

			if user.team && user.team.contract.target
				can :read, User.all do |can_user|
					user.team.contract.target.members.include? can_user
				end
			end
			
			can :manage, user
			cannot :destroy, user
		end

		can :manage, :all if user.admin?
	end
end
