class AddLoginIdAndRoleToUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :users, bulk: true do |t|
      t.string :login_id
      t.integer :role, null: false, default: 0
    end
    add_index :users, :login_id, unique: true
  end
end
