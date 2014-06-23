class Game < ActiveRecord::Base
	has_many :kills, dependent: :destroy
	has_many :neutralizations, dependent: :destroy
	has_many :participations, dependent: :destroy
	
	has_many :contracts, through: :participations
	has_many :teams, through: :participations

	validates :name, presence: true

	def completed?
		self.ended_at && !self.in_progress
	end

	# All of the users in the game.
	def users
		self.teams.map { |team| team.members }.flatten
	end

	def suggested_team_fee
		users.empty? ? 0.0 : (users.map { |user| user.willing_to_pay_amount }.sum / users.size.to_f * 4.0)
	end
end
