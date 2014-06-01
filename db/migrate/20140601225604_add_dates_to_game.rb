class AddDatesToGame < ActiveRecord::Migration
  def change
    add_column :games, :started_at, :datetime
    add_column :games, :ended_at, :datetime
  end
end
