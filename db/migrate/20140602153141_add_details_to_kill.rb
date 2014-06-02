class AddDetailsToKill < ActiveRecord::Migration
  def change
    add_column :kills, :occurred_at, :datetime
    add_column :kills, :picture_url, :string
  end
end
