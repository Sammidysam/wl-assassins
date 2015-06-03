class Team < ActiveRecord::Base
	has_many :games, through: :participations
	has_many :kills, foreign_key: "killer_id"
	has_many :memberships, dependent: :destroy
	has_many :participations, dependent: :destroy
	has_many :target_contracts, class_name: "Contract", foreign_key: "target_id", dependent: :destroy
	has_many :users, through: :memberships
	has_many :name_changes

	validates :name, presence: true, uniqueness: true

	nilify_blanks

	# Returns the teams that are not in game.
	def self.not_in_game(game)
		all.select do |team|
			!game.teams.map { |inner_team| inner_team.id }.include? team.id
		end
	end

	# Returns the members of the team.
	def members(game_id = nil)
		if game_id
			# Return members of the team during this game.
			game = Game.find(game_id)
			created_before_game = self.memberships.where("created_at < ?", game.started_at)

			retrieval_memberships = created_before_game.where(ended_at: nil).where.not(started_at: nil) + created_before_game.where.not(ended_at: nil).where("ended_at > ?", game.ended_at)
		else
			# Return active members of the team.
			retrieval_memberships = self.memberships.where(ended_at: nil).where.not(started_at: nil)
		end

		User.where(id: retrieval_memberships.map { |membership| membership.user_id })
	end

	def alive_members
		members.select { |member| member.alive? }
	end

	def dead_members
		members.select { |member| member.dead? }
	end

	def member_kills(game_id = nil)
		Kill.where(target_id: members(game_id).map { |member| member.id })
	end

	# Returns the current participation for the team.
	def participation
		in_progress_game_ids = Game.where(in_progress: true).ids
		self.participations.find_by game_id: in_progress_game_ids
	end

	def in_game?
		!participation.nil?
	end

	def eliminated?(game_id = (participation ? participation.game_id : nil))
		members(game_id).all? { |member| member.dead?(game_id) }
	end

	def last_confirmed_kill(game_id)
		confirmed_kills = member_kills(game_id).where(game_id: game_id, confirmed: true)
		confirmed_kills.sort_by { |kill| kill.appear_at || kill.created_at }.last
	end

	# Returns time of the confirmation of the last kill for this team.
	def eliminated_at(game_id = (participation ? participation.game_id : nil))
		last_confirmed_kill(game_id) ? (last_confirmed_kill(game_id).appear_at || last_confirmed_kill(game_id).created_at) : nil
	end

	# Returns the team that killed this team.
	def killer(game_id = (participation ? participation.game_id : nil))
		last_confirmed_kill(game_id) ? last_confirmed_kill(game_id).killer : nil
	end

	def terminators?(game_id = participation ? participation.game_id : nil)
		game_participation = self.participations.find_by game_id: game_id
		game_participation.terminators if game_participation
	end

	# Returns true if all of the alive members of the team are out-of-town.
	def out_of_town?
		alive_members.count > 0 && alive_members.all? { |member| member.out_of_town }
	end

	# A team is disbanded if it has no active members.
	def disbanded?
		self.memberships.where(ended_at: nil).where.not(started_at: nil).empty?
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
		Neutralization.where(target_id: members.ids)
	end

	def remaining_out_of_town_end
		out_of_town? ? member_kills.out_of_town.where(confirmed: false, game_id: participation.game_id).first.appear_at : (24 - participation.out_of_town_hours).hours.from_now
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

	def out_of_town_kill
		alive_members.each do |member|
			kill = Kill.new
			kill.target_id = member.id
			kill.kind = "out_of_town"
			kill.game_id = participation.game_id
			kill.appear_at = (24 - participation.out_of_town_hours).hours.from_now

			kill.save
		end
	end

	def out_of_town_kills
		Kill.out_of_town.where(confirmed: false, target_id: members.map { |member| member.id }, game_id: participation.game_id).where.not(appear_at: nil)
	end

	def remove_out_of_town_kills
		out_of_town_kills.destroy_all
	end

	# The points this team has for comparison 2015.
	def points(game_id)
	end
end
