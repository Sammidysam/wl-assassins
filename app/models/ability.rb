class Ability
	include CanCan::Ability

	def initialize(user)
		logged_in = true if user
		
		# If user is not logged in, make them be a guest user.
		user ||= User.new

		can :create, User

		can :read, Game
		can :read, Page

		if logged_in
			can :manage, Team.all do |team|
				team.users.include? user
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
