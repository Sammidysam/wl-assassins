class AddTeamFeeToGame < ActiveRecord::Migration
  def change
    add_column :games, :team_fee, :float
  end
end
