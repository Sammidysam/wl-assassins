class AddLogoUrlToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :logo_url, :string
  end
end
