class AddTerminationAtToParticipation < ActiveRecord::Migration
  def change
    add_column :participations, :termination_at, :datetime
  end
end
