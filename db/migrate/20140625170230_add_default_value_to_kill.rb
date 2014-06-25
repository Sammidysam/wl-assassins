class AddDefaultValueToKill < ActiveRecord::Migration
	def change
		change_column_default :kills, :confirmed, false
	end
end
