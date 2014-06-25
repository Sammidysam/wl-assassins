class AddDefaultValueToContract < ActiveRecord::Migration
	def change
		change_column_default :contracts, :completed, false
	end
end
