class Membership < ActiveRecord::Base
	belongs_to :team
	belongs_to :user

	validate :user_cannot_be_on_team_twice

	# Ensure that a user is not actively on the same team twice.
	# Retrieves all of the memberships matching these conditions, then checks how many besides this membership exist.
	# If that count is greater than 0, then the user should not be added to the team.
	def user_cannot_be_on_team_twice
		errors.add :user_id, "cannot be on team twice" if Membership.where(active: true, user_id: self.user_id, team_id: self.team_id).select { |membership| membership.id != self.id }.count > 0
	end
end
