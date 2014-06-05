class RemoveRenderFromPage < ActiveRecord::Migration
  def change
    remove_column :pages, :render, :string
  end
end
