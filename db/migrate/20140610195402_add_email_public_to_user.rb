class AddEmailPublicToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_public, :boolean
  end
end
