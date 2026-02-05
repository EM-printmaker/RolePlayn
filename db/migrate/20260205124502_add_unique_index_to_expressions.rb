class AddUniqueIndexToExpressions < ActiveRecord::Migration[7.2]
  def change
    add_index :expressions, [ :level, :character_id, :emotion_type ],
              unique: true,
              name: 'idx_expressions_unique_set'
  end
end
