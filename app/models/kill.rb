class Kill < ActiveRecord::Base
	enum kind: [ :assassination, :termination, :out_of_town, :out_of_time, :disqualification, :quitting ]

	belongs_to :game

	belongs_to :killer, class_name: "Team"
	belongs_to :target, class_name: "User"

	validate :target_must_be_alive, on: :create
	validate :target_must_be_on_target_team, on: :create

	validates :killer_id, presence: true, if: Proc.new { |kill| kill.kind == "assassination" }
	validates :game_id, :target_id, presence: true

	nilify_blanks

	def target_must_be_alive
		errors.add :target_id, "must be alive" unless User.find(target_id).alive?
	end

	def target_must_be_on_target_team
		errors.add :target_id, "must be on target team" if self.assassination? && (!target.team || killer.target.id != target.team.id)
	end

	# Returns when this is an event.
	# date is a pointless argument to maintain compatibility with Neutralization.
	def event_time(date)
		self.confirmed_at
	end

	def self.readable_kind_number(number)
		case number
		when 0
			"assassination"
		when 1
			"termination"
		when 2
			"being out-of-town at the wrong time for too long"
		when 3
			"running out of time to conduct a kill"
		when 4
			"disqualification"
		when 5
			"quitting"
		end
	end

	def readable_kind
		case self.kind
		when "out_of_town"
			"being out-of-town at the wrong time for too long"
		when "out_of_time"
			"running out of time to conduct a kill"
		else
			self.kind
		end
	end

	# How many points in comparison 2015 this kill yields.
	def points(game_id)
	end
end
