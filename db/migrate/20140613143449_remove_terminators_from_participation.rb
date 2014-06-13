class RemoveTerminatorsFromParticipation < ActiveRecord::Migration
  def change
    remove_column :participations, :terminators, :boolean
  end
end
