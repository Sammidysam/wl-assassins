class Neutralization < ActiveRecord::Base
	belongs_to :game
	
	belongs_to :killer, class_name: "User"
	belongs_to :target, class_name: "User"

	validates :confirmed, :killer_id, :target_id, :game_id, presence: true

	nilify_blanks

	# Returns the end of the neutralization.
	def end_time
		start + 1.day
	end

	# Returns when this is an event.
	def event_time(date)
		self.start === date.beginning_of_day..date.end_of_day ? self.start : end_time
	end
end
