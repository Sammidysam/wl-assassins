class AddPaidAmountToParticipation < ActiveRecord::Migration
  def change
    add_column :participations, :paid_amount, :float
  end
end
