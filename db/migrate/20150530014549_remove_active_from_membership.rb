class RemoveActiveFromMembership < ActiveRecord::Migration
  def change
    remove_column :memberships, :active, :boolean
  end
end
