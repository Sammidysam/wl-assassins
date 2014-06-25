class AddDefaultValueToNeutralization < ActiveRecord::Migration
	def change
		change_column_default :neutralizations, :confirmed, false
	end
end
