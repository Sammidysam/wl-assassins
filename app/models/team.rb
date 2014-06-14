class Team < ActiveRecord::Base
	has_many :memberships
	has_many :participations
	
	has_many :games, through: :participations
	has_many :users, through: :memberships
	
	validates :name, presence: true, uniqueness: true

	nilify_blanks

	# Returns only the user who are current members of team.
	def members
		self.memberships.where(active: true).map { |membership| membership.user }
	end

	# Returns the current participation for the team.
	def participation
		self.participations.find { |participation| participation.game.in_progress if participation.game }
	end

	# Returns the current contract for the team.
	def contract
		participation.contracts.find { |contract| !contract.completed } if participation
	end

	# Returns the current target for the team.
	def target
		contract.target if contract
	end
end
