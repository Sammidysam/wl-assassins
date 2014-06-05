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
			can :manage, user
			cannot :destroy, user
		end

		can :manage, :all if user.admin?
	end
end
