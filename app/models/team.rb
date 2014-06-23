class Team < ActiveRecord::Base
	has_many :games, through: :participations
	has_many :kills, foreign_key: "killer_id"
	has_many :memberships, dependent: :destroy
	has_many :participations, dependent: :destroy
	has_many :target_contracts, class_name: "Contract", foreign_key: "target_id", dependent: :destroy
	has_many :users, through: :memberships
	
	validates :name, presence: true, uniqueness: true

	nilify_blanks

	# Returns the teams that are not in game.
	def self.not_in_game(game)
		all.select do |team|
			!game.teams.map { |inner_team| inner_team.id }.include? team.id
		end
	end

	# Returns only the user who are current members of team.
	def members
		self.memberships.where(active: true).map { |membership| membership.user }
	end

	# Returns the current participation for the team.
	def participation
		self.participations.find { |participation| participation.game.in_progress if participation.game }
	end

	def in_game?
		!participation.nil?
	end

	def terminators?
		participation.terminators
	end

	# Returns the current contract for the team.
	def contract
		participation.contracts.find { |contract| !contract.completed } if participation
	end

	# Returns the current target for the team.
	def target
		contract.target if contract
	end
	
	def remaining_kill_time
		participation.termination_at - DateTime.now if participation
	end
end
