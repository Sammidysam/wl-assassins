class CreateNeutralizations < ActiveRecord::Migration
  def change
    create_table :neutralizations do |t|
      t.boolean :confirmed
      t.datetime :start
      t.integer :killer_id
      t.integer :target_id
      t.integer :game_id

      t.timestamps
    end
  end
end
