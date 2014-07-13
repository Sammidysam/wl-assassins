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

	def pregame?
		!completed? && !self.in_progress
	end

	# All of the users in the game.
	def users
		self.teams.map { |team| team.members }.flatten
	end

	def remaining_teams
		self.teams.select { |team| !team.eliminated? && !team.terminators? }
	end

	def eliminated_teams
		self.teams.select { |team| team.eliminated?(self.id) && !team.terminators?(self.id) }
	end

	def winner
		self.teams.find do |team|
			!team.participations.find_by(game_id: self.id).terminators && !team.members.all? do |member|
				member.kills.find_by(game_id: self.id, confirmed: true)
			end
		end
	end

	def prize_money
		self.participations.where(terminators: false).sum(:paid_amount)
	end

	# Returns the teams in order of their place.
	def placement_order_teams
		self.teams.select { |team| !team.terminators?(self.id) && team.id != winner.id }.sort do |x, y|
			x_last_confirmed_kill = x.last_confirmed_kill(self.id)
			y_last_confirmed_kill = y.last_confirmed_kill(self.id)
			
			if x_last_confirmed_kill.out_of_time? && y_last_confirmed_kill.out_of_time? && ((x_last_confirmed_kill.appear_at - y_last_confirmed_kill.appear_at) / 1.minute).abs < 2
				y.kills.where(game_id: self.id, confirmed: true).count + y.target_neutralizations.where(game_id: self.id, confirmed: true).count <=> x.kills.where(game_id: self.id, confirmed: true).count + x.target_neutralizations.where(game_id: self.id, confirmed: true).count
			else
				y.eliminated_at(self.id) <=> x.eliminated_at(self.id)
			end
		end
	end

	# All of the users sans terminators in the game.
	def participants
		self.teams.select { |team| !team.participations.find_by(game_id: self.id).terminators }.map { |inner_team| inner_team.members }.flatten
	end

	def suggested_team_fee
		participants.empty? ? 0.0 : (participants.map { |participant| participant.willing_to_pay_amount }.sum / participants.size.to_f * 4.0)
	end
end
