class AddSlugToCities < ActiveRecord::Migration[7.2]
  def change
    add_column :cities, :slug, :string
    add_index :cities, :slug, unique: true
  end
end
