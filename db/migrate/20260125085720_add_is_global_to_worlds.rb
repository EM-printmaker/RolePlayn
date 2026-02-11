class AddIsGlobalToWorlds < ActiveRecord::Migration[7.2]
  def change
    add_column :worlds, :is_global, :boolean, null: false, default: false
  end
end
