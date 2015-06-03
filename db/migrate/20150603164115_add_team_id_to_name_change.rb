class AddTeamIdToNameChange < ActiveRecord::Migration
  def change
    add_reference :name_changes, :team, index: true, foreign_key: true
  end
end
