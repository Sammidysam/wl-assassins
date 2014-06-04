class RemoveWelcomeFromPage < ActiveRecord::Migration
  def change
    remove_column :pages, :welcome, :boolean
  end
end
