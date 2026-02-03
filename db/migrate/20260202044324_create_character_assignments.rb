class CreateCharacterAssignments < ActiveRecord::Migration[7.2]
  def change
    create_table :character_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.references :character, null: false, foreign_key: true
      t.references :expression, null: false, foreign_key: true
      t.date :assigned_date, null: false

      t.timestamps
    end
    add_index :character_assignments, [ :user_id, :city_id, :assigned_date ], unique: true, name: "unique_character_per_user_city_day"
  end
end
