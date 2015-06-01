class Game < ActiveRecord::Base
	include DistanceOfTimeInWords

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

	def prize_money
		self.participations.where(terminators: false).sum(:paid_amount)
	end

	def expected_money
		self.team_fee * self.participations.where(terminators: false).count
	end

	def comparison_2014(x, y)
		# Use tiebreaker when teams were eliminated less than 2 minutes from each other.
		if ((x.eliminated_at(self.id) - y.eliminated_at(self.id)) / 1.minute).abs < 2
			y.kills.where(game_id: self.id, confirmed: true).count + (0.5 * y.target_neutralizations.where(game_id: self.id, confirmed: true).count) <=> x.kills.where(game_id: self.id, confirmed: true).count + (0.5 * x.target_neutralizations.where(game_id: self.id, confirmed: true).count)
		else
			y.eliminated_at(self.id) <=> x.eliminated_at(self.id)
		end
	end

	def comparison_2015(x, y)
		# Need to sort top 4 by eliminated_at
		x.points(self.id) <=> y.points(self.id)
	end

	# Returns the teams in order of their place.
	def place_teams
		failed = false

		teams = self.teams
		winner = teams.find do |team|
            !team.participations.find_by(game_id: self.id).terminators && !team.members.all? do |member|
                member.kills.find_by(game_id: self.id, confirmed: true)
            end
        end

		team_ids_to_sort = self.participations.where(terminators: false).where.not(team_id: winner.id).collect(&:team_id)
		teams_to_sort = Team.where(id: team_ids_to_sort)

		sorting_comparison = case self.ended_at.year
		                     when 2014
			                     :comparison_2014
		                     else
			                     :comparison_2014
		                     end

		sorted_teams = teams_to_sort.sort { |x, y| send sorting_comparison, x, y }

		# The hash will be of format:
		#   key: place (e.g. 3)
		#   value: array of teams of that place
		# For example:
		#   { 2 => [team id 5], 3 => [team id 7, team id 15] }
		order_hash = {}

		sorted_teams.each_with_index do |team, index|
			next if order_hash.values.flatten.map { |inner_team| inner_team.id }.include?(team.id)

			teams = [team]

			# Check if this team is tied with any of the next teams.
			while sorted_teams[index + 1]
				if send(sorting_comparison, team, sorted_teams[index + 1]) == 0
					teams << sorted_teams[index + 1]
				else
					break
				end

				index += 1
			end

			# Add to the hash.
			last_key = order_hash.keys.sort.last
			new_item = { (last_key ? last_key + order_hash[last_key].count : 2) => teams }
			order_hash.merge! new_item
		end

		winner_participation = self.participations.find_by(team_id: winner.id)
		winner_participation.place = 1
		failed ||= !winner_participation.save

		order_hash.each do |key, value|
			value.each do |team|
				participation = self.participations.find_by(team_id: team.id)
				participation.place = key
				failed ||= !participation.save
			end
		end

		!failed
	end

	# All of the users sans terminators in the game.
	def participants
		self.teams.select { |team| !team.participations.find_by(game_id: self.id).terminators }.map { |inner_team| inner_team.members }.flatten
	end

	def suggested_team_fee
		participants.empty? ? 0.0 : (participants.map { |participant| participant.willing_to_pay_amount }.sum / participants.size.to_f * 4.0)
	end

	# The teams that are to be terminated.
	def to_be_terminated
		self.teams.select do |team|
            !team.terminators? && !team.eliminated? && precise_distance_of_time_in_words_to_now(team.participation.termination_at, interval: :day) == 0 && team.participation.termination_at > DateTime.now
        end.sort_by do |inner_team|
            inner_team.participation.termination_at
        end
	end
end
