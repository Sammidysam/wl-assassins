class RenameOccurredAtToConfirmedAtInKill < ActiveRecord::Migration
	def change
		rename_column :kills, :occurred_at, :confirmed_at
	end
end
