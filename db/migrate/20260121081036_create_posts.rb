class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.text :content
      t.references :character, null: false, foreign_key: true
      t.references :expression, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true

      t.timestamps
    end
    add_index :posts, [ :character_id, :created_at ]
    add_index :posts, [ :city_id, :created_at ]
    add_index :posts, [ :created_at ]
  end
end
