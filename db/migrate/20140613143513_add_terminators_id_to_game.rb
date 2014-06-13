class AddTerminatorsIdToGame < ActiveRecord::Migration
  def change
    add_column :games, :terminators_id, :integer
  end
end
