class Membership < ActiveRecord::Base
	belongs_to :team
	belongs_to :user

	validate :admin_cannot_be_on_team
	validate :team_cannot_have_more_than_four_members
	validate :user_cannot_be_on_team_twice, on: :create
	validate :cannot_send_multiple_invitations, on: :create
	validate :user_cannot_be_duplicate

	validates :team_id, :user_id, presence: true

	# Ensures that no admins are on a team.
	def admin_cannot_be_on_team
		errors.add :user_id, "cannot be an admin" if User.find(user_id).admin?
	end

	# A team cannot have four or more members before a new membership is added.
	# If it does, the member count will exceed the maximum, four.
	def team_cannot_have_more_than_four_members
		errors.add :team, "cannot have more than four members" if Team.find(team_id).members.count >= 4
	end

	# Ensure that a user is not actively on the same team twice.
	# Retrieves all of the active memberships that are the same as this one sans id,
	# and ensures that none exist.
	def user_cannot_be_on_team_twice
		errors.add :user_id, "cannot be on team twice" unless Membership.where(ended_at: nil, user_id: self.user_id, team_id: self.team_id).where.not(started_at: nil).empty?
	end

	# Only one invitation can be sent to someone.
	def cannot_send_multiple_invitations
		errors.add :user_id, "has already been invited" unless Membership.where(started_at: nil, user_id: self.user_id, team_id: self.team_id).empty?
	end

	def user_cannot_be_duplicate
		errors.add :user_id, "cannot be duplicate" if User.find(user_id).duplicate
	end

	def active?
		self.started_at && !self.ended_at
	end
end
