class Contract < ActiveRecord::Base
	belongs_to :participation
	belongs_to :target, class_name: "Team"

	validates :participation_id, :target_id, :start, presence: true

	# Returns the next team in the order that is not eliminated.
	def next_non_eliminated_target
		contract = self

		while !contract.target.eliminated?
			contract = contract.target.contract
		end

		contract
	end
end
