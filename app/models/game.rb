class Game < ActiveRecord::Base
	has_many :neutralizations
	has_many :participations
	
	has_many :contracts, through: :participations
	has_many :kills, through: :participations
	has_many :teams, through: :participations

	validates :name, presence: true

	def completed?
		self.ended_at && !self.in_progress
	end

	# All of the users in the game.
	def users
		self.teams.map { |team| team.members }.flatten
	end

	def participants
		self.teams.select { |team| !team.participations.find_by(game_id: self.id).terminators }.map { |team| team.members }.flatten
	end

	def suggested_team_fee
		participants.empty? ? 0.0 : (participants.map { |participant| participant.willing_to_pay_amount }.sum / participants.size.to_f * 4.0)
	end
end
