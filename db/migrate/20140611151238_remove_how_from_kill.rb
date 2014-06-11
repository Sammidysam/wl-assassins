class RemoveHowFromKill < ActiveRecord::Migration
  def change
    remove_column :kills, :how, :string
  end
end
