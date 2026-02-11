class RemoveFavoritesTable < ActiveRecord::Migration[7.2]
  def up
    drop_table :favorites
  end

  def down
    create_table :favorites do |t|
    t.references :user, null: false, foreign_key: true
    t.references :favoritable, polymorphic: true, null: false
    t.timestamps
    end
  add_index :favorites, [ :user_id, :favoritable_type, :favoritable_id ], unique: true, name: 'unique_favorites'
  end
end
