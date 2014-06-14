class Kill < ActiveRecord::Base
	enum type: [ :assassination, :termination, :out_of_town ]
	
	belongs_to :participation
	
	belongs_to :target, class_name: "User"

	validates :participation_id, :target_id, presence: true

	nilify_blanks

	# Returns when this is an event.
	# date is a pointless argument to maintain compatibility with Neutralization.
	def event_time(date)
		self.occurred_at
	end

	# Returns the team that conducted the kill.
	def team
		self.participation.team
	end
end
