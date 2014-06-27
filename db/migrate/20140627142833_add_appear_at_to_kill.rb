class AddAppearAtToKill < ActiveRecord::Migration
  def change
    add_column :kills, :appear_at, :datetime
  end
end
