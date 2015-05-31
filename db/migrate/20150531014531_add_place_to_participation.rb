class AddPlaceToParticipation < ActiveRecord::Migration
  def change
    add_column :participations, :place, :integer
  end
end
