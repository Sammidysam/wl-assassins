class Team < ActiveRecord::Base
	has_many :memberships
	has_many :participations
	
	has_many :games, through: :participations
	has_many :users, through: :memberships

	validates :name, presence: true

	# Returns only the user who are current members of team.
	def members
		self.memberships.map { |membership| membership.user if membership.active }
	end
end
