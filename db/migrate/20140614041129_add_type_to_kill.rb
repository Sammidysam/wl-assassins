class AddTypeToKill < ActiveRecord::Migration
  def change
    add_column :kills, :type, :integer, default: 0
  end
end
