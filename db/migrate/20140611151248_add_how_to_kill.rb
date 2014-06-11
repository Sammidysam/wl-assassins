class AddHowToKill < ActiveRecord::Migration
  def change
    add_column :kills, :how, :text
  end
end
