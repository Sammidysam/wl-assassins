class AddStartedAtToMembership < ActiveRecord::Migration
  def change
    add_column :memberships, :started_at, :datetime
  end
end
