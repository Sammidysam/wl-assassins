class RemoveTerminatorsIdFromGame < ActiveRecord::Migration
  def change
    remove_column :games, :terminators_id, :integer
  end
end
