class AddKindToKill < ActiveRecord::Migration
  def change
    add_column :kills, :kind, :integer, default: 0
  end
end
