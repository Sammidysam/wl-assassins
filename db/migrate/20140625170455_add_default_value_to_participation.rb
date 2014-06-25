class AddDefaultValueToParticipation < ActiveRecord::Migration
	def change
		change_column_default :participations, :terminators, false
	end
end
