class AddDatesToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :start, :datetime
    add_column :contracts, :end, :datetime
  end
end
