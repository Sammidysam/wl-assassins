class AddRenderToPage < ActiveRecord::Migration
  def change
    add_column :pages, :render, :string
  end
end
