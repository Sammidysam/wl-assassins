class AddLinkToPage < ActiveRecord::Migration
  def change
    add_column :pages, :link, :string
  end
end
