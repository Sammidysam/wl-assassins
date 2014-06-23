class Kill < ActiveRecord::Base
	enum kind: [ :assassination, :termination, :out_of_town, :disqualified, :quit ]

	belongs_to :game

	belongs_to :killer, class_name: "Team"
	belongs_to :target, class_name: "User"

	validate :killer_must_not_be_nil_sometimes, on: :create
	validate :target_must_be_alive, on: :create
	validate :target_must_be_on_target_team, on: :create

	validates :game_id, :target_id, presence: true

	nilify_blanks

	def killer_must_not_be_nil_sometimes
		errors.add :killer_id, "must not be nil" if self.killer_id.nil? && self.kind == "assassination"
	end

	def target_must_be_alive
		errors.add :target_id, "must be alive" unless User.find(target_id).alive?
	end

	def target_must_be_on_target_team
		errors.add :target_id, "must be on target team" if self.assassination? && (!target.team || killer.target.id != target.team.id)
	end

	# Returns when this is an event.
	# date is a pointless argument to maintain compatibility with Neutralization.
	def event_time(date)
		self.occurred_at
	end
end
