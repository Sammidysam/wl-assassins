class CreateKills < ActiveRecord::Migration
  def change
    create_table :kills do |t|
      t.boolean :confirmed
      t.string :how
      t.integer :participation_id
      t.integer :target_id

      t.timestamps
    end
  end
end
