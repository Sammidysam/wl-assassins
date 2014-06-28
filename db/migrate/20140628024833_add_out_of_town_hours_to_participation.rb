class AddOutOfTownHoursToParticipation < ActiveRecord::Migration
	def change
		add_column :participations, :out_of_town_hours, :float, default: 0.0
	end
end
