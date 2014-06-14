class RemoveTypeFromKill < ActiveRecord::Migration
  def change
    remove_column :kills, :type, :integer
  end
end
