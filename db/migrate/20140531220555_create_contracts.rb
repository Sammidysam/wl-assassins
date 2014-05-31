class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.boolean :completed
      t.integer :participation_id
      t.integer :target_id

      t.timestamps
    end
  end
end
