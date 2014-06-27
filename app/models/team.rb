class Team < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
	
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

	# Returns the teams that are to be terminated.
	def self.to_be_terminated(game)
		game.teams.select do |team|
			!team.terminators? && team.remaining_kill_time.in_days.floor == 0 && team.participation.termination_at > DateTime.now
		end.sort_by do |inner_team|
			inner_team.participation.termination_at
		end
	end

	# Returns only the user who are current members of team.
	def members
		self.memberships.where(active: true).map { |membership| membership.user }
	end

	def alive_members
		members.select { |member| member.alive? }
	end

	# Returns the current participation for the team.
	def participation
		self.participations.find { |participation| participation.game.in_progress if participation.game }
	end

	def in_game?
		!participation.nil?
	end

	def eliminated?
		members.all? { |member| member.dead? }
	end

	def terminators?
		participation.terminators if participation
	end

	# Returns the current contract for the team.
	def contract
		participation.contracts.find { |contract| !contract.completed } if participation
	end

	def completed_contracts
		participation.contracts.where(completed: true)
	end

	# Returns the current target for the team.
	def target
		contract.target if contract
	end
	
	def remaining_kill_time
		TimeDifference.between(participation.termination_at, Time.now) if participation
	end

	def remaining_kill_time_format
		components = []
		
		components << pluralize(remaining_kill_time.in_days.floor, "day") if remaining_kill_time.in_days.floor > 0
		components << pluralize(remaining_kill_time.in_hours.floor - remaining_kill_time.in_days.floor * 24, "hour") if remaining_kill_time.in_hours.floor > 0
		components << pluralize(remaining_kill_time.in_minutes.floor - remaining_kill_time.in_hours.floor * 60, "minute") if remaining_kill_time.in_minutes.floor > 0

		components.to_sentence
	end

	def autoterminate
		# Terminate all members of team.
		alive_members.each do |member|
			kill = Kill.new
			kill.target_id = member.id
			kill.kind = "out_of_time"
			kill.game_id = participation.game_id

			kill.save
		end
	end
end
