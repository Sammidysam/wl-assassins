class AddWelcomeToPage < ActiveRecord::Migration
  def change
    add_column :pages, :welcome, :boolean
  end
end
