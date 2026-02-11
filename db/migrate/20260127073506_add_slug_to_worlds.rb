class AddSlugToWorlds < ActiveRecord::Migration[7.2]
  def change
    add_column :worlds, :slug, :string
    add_index :worlds, :slug, unique: true
  end
end
