class Contract < ActiveRecord::Base
	belongs_to :participation
	belongs_to :target, class_name: "Team"

	validates :completed, :participation_id, :target_id, :start, presence: true
end
