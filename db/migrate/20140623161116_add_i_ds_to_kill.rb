class AddIDsToKill < ActiveRecord::Migration
  def change
    add_column :kills, :game_id, :integer
    add_column :kills, :killer_id, :integer
  end
end
