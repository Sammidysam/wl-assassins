class RemovePaidAmountFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :paid_amount, :float
  end
end
