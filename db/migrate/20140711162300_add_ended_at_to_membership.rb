class AddEndedAtToMembership < ActiveRecord::Migration
  def change
    add_column :memberships, :ended_at, :datetime
  end
end
