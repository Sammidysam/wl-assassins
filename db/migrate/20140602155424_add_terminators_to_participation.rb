class AddTerminatorsToParticipation < ActiveRecord::Migration
  def change
    add_column :participations, :terminators, :boolean
  end
end
