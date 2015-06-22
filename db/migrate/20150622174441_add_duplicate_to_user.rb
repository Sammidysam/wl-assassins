class AddDuplicateToUser < ActiveRecord::Migration
  def change
    add_column :users, :duplicate, :boolean, default: false
  end
end
