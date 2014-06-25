class Membership < ActiveRecord::Base
	belongs_to :team
	belongs_to :user

	validate :admin_cannot_be_on_team
	validate :team_cannot_have_more_than_four_members, on: :create
	validate :user_cannot_be_on_team_twice, on: :create

	validates :team_id, :user_id, presence: true

	# Ensures that no admins are on a team.
	def admin_cannot_be_on_team
		errors.add :user_id, "cannot be an admin" if User.find(user_id).admin?
	end

	# A team cannot have four or more members before a new membership is added.
	# If it does, the member count will exceed the maximum, four.
	def team_cannot_have_more_than_four_members
		errors.add :team, "cannot have four members" if Team.find(team_id).members.count >= 4
	end

	# Ensure that a user is not actively on the same team twice.
	# Retrieves all of the active memberships that are the same as this one sans id,
	# and ensures that none exist.
	def user_cannot_be_on_team_twice
		errors.add :user_id, "cannot be on team twice" unless Membership.where(active: true, user_id: self.user_id, team_id: self.team_id).empty?
	end
end
