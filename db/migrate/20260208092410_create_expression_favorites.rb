class CreateExpressionFavorites < ActiveRecord::Migration[7.2]
  def change
    create_table :expression_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :expression, null: false, foreign_key: true
      t.timestamps
    end
    add_index :expression_favorites, [ :user_id, :expression_id ], unique: true
  end
end
