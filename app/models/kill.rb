class Kill < ActiveRecord::Base
	enum kind: [ :assassination, :termination, :out_of_town, :quit ]
	
	belongs_to :participation
	
	belongs_to :target, class_name: "User"

	validate :target_must_be_alive, on: :create
	validate :target_must_be_on_target_team, on: :create

	validates :target_id, presence: true

	nilify_blanks

	def target_must_be_alive
		errors.add :target_id, "must be alive" unless User.find(target_id).alive?
	end

	def target_must_be_on_target_team
		participation = Participation.find(participation_id)
		
		errors.add :target_id, "must be on target team" if !target.team || !participation || participation.team.target.id != target.team.id
	end

	# Returns when this is an event.
	# date is a pointless argument to maintain compatibility with Neutralization.
	def event_time(date)
		self.occurred_at
	end

	# Returns the team that conducted the kill.
	def team
		self.participation.team if self.participation
	end
end
