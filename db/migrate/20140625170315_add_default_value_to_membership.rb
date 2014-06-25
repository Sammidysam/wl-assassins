class AddDefaultValueToMembership < ActiveRecord::Migration
	def change
		change_column_default :memberships, :active, false
	end
end
