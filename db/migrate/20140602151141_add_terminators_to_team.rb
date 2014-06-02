class AddTerminatorsToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :terminators, :boolean
  end
end
