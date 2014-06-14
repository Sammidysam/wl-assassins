class AddPictureUrlToNeutralization < ActiveRecord::Migration
  def change
    add_column :neutralizations, :picture_url, :string
  end
end
