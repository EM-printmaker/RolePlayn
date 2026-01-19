class CreateExpressions < ActiveRecord::Migration[7.2]
  def change
    create_table :expressions do |t|
      t.integer :emotion_type
      t.integer :level
      t.references :character, null: false, foreign_key: true

      t.timestamps
    end
  end
end
