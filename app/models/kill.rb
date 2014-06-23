class Kill < ActiveRecord::Base
	enum kind: [ :assassination, :termination, :out_of_town, :disqualified, :quit ]

	belongs_to :game

	belongs_to :killer, class_name: "Team"
	belongs_to :target, class_name: "User"

	validate :target_must_be_alive, on: :create
	validate :target_must_be_on_target_team, on: :create

	validates :target_id, presence: true

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
		self.occurred_at
	end
end
