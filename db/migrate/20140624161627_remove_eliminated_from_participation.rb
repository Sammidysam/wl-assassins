class RemoveEliminatedFromParticipation < ActiveRecord::Migration
  def change
    remove_column :participations, :eliminated, :boolean
  end
end
