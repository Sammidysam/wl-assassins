class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :phone_number
      t.boolean :phone_number_public
      t.string :address
      t.boolean :address_public
      t.integer :graduation_year
      t.text :description
      t.string :profile_picture_url
      t.boolean :admin
      t.boolean :out_of_town
      t.float :willing_to_pay_amount
      t.float :paid_amount

      t.timestamps
    end
  end
end
