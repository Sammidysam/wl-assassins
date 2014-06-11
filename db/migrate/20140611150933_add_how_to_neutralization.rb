class AddHowToNeutralization < ActiveRecord::Migration
  def change
    add_column :neutralizations, :how, :text
  end
end
