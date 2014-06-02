class RemoveTerminatorsFromTeam < ActiveRecord::Migration
  def change
    remove_column :teams, :terminators, :boolean
  end
end
