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
			!team.terminators? && !team.eliminated? && team.remaining_kill_time.in_days.floor == 0 && team.participation.termination_at > DateTime.now
		end.sort_by do |inner_team|
			inner_team.participation.termination_at
		end
	end

	# Returns only the user who are current members of team.
	def members
		active_memberships = self.memberships.where(active: true)
		User.find(active_memberships.map { |membership| membership.user_id })
	end

	def alive_members
		members.select { |member| member.alive? }
	end

	def dead_members
		members.select { |member| member.dead? }
	end

	def member_kills
		Kill.where(target_id: members.map { |member| member.id })
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

	def last_confirmed_kill
		members.map { |member| member.kills.where(game_id: participation.game_id, confirmed: true) }.flatten.sort_by { |kill| kill.confirmed_at }.last
	end

	# Returns time of the confirmation of the last kill for this team.
	def eliminated_at
		last_confirmed_kill.confirmed_at if eliminated?
	end

	# Returns the team that killed this team.
	def killer
		last_confirmed_kill.killer if eliminated?
	end

	def terminators?
		participation.terminators if participation
	end

	# Returns true if all of the alive members of the team are out-of-town.
	def out_of_town?
		alive_members.count > 0 && alive_members.all? { |member| member.out_of_town }
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

	# Returns all of the neutralizations that the team conducted.
	def target_neutralizations
		members.map { |member| member.target_neutralizations }.flatten
	end
	
	def remaining_kill_time
		TimeDifference.between(participation.termination_at, Time.now) if participation
	end

	def remaining_kill_time_format
		components = []
		
		components << pluralize(remaining_kill_time.in_days.floor, "day") if remaining_kill_time.in_days.floor > 0
		components << pluralize(remaining_kill_time.in_hours.floor - remaining_kill_time.in_days.floor * 24, "hour") if remaining_kill_time.in_hours.floor - remaining_kill_time.in_days.floor * 24 > 0
		components << pluralize(remaining_kill_time.in_minutes.floor - remaining_kill_time.in_hours.floor * 60, "minute") if remaining_kill_time.in_minutes.floor - remaining_kill_time.in_hours.floor * 60 > 0

		participation.termination_at > DateTime.now ? components.to_sentence : "no time"
	end

	def remaining_out_of_town_time
		TimeDifference.between(out_of_town? ? member_kills.out_of_town.where(confirmed: false, game_id: participation.game_id).first.appear_at : (24 - participation.out_of_town_hours).hours.from_now, Time.now)
	end

	def remaining_out_of_town_time_format(more = true)
		components = []

		components << pluralize(remaining_out_of_town_time.in_hours.floor, "hour") if remaining_out_of_town_time.in_hours.floor > 0
		components << pluralize(remaining_out_of_town_time.in_minutes.floor - remaining_out_of_town_time.in_hours.floor * 60, "minute") if remaining_out_of_town_time.in_minutes.floor - remaining_out_of_town_time.in_hours.floor * 60 > 0

		(out_of_town? && DateTime.now > member_kills.out_of_town.where(confirmed: false, game_id: participation.game_id).first.appear_at) ? "no #{"more " if more}time" : "#{components.to_sentence}#{" more" if more}"
	end

	def autoterminate
		# Terminate all members of team.
		alive_members.each { |member| member.autoterminate }
	end

	def autoterminations
		Kill.out_of_time.where(confirmed: false, target_id: members.map { |member| member.id }, game_id: participation.game_id).where.not(appear_at: nil)
	end

	def remove_autotermination
		autoterminations.destroy_all
	end
end
