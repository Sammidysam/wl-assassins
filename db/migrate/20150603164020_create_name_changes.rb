class CreateNameChanges < ActiveRecord::Migration
  def change
    create_table :name_changes do |t|
      t.string :from
      t.string :to

      t.timestamps null: false
    end
  end
end
