class AddDefaultValueToGame < ActiveRecord::Migration
	def change
		change_column_default :games, :in_progress, false
	end
end
