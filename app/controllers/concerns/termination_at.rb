module TerminationAt
	extend ActiveSupport::Concern

	def next_termination_at(teams_count)
		case teams_count
		when 2
			3
		when 3..4
			4
		else
			5
		end.days.from_now
	end
end
