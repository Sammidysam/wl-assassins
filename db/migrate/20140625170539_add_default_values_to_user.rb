class AddDefaultValuesToUser < ActiveRecord::Migration
	def change
		change_column_default :users, :phone_number_public, false
		change_column_default :users, :address_public, false
		change_column_default :users, :out_of_town, false
		change_column_default :users, :email_public, false
	end
end
