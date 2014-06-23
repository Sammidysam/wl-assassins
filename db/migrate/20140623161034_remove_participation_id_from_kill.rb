class RemoveParticipationIdFromKill < ActiveRecord::Migration
  def change
    remove_column :kills, :participation_id, :integer
  end
end
