class AddLockableToDevise < ActiveRecord::Migration[7.2]
  def change
    change_table :users, bulk: true do |t|
      t.integer :failed_attempts, :integer, default: 0, null: false
      t.datetime :locked_at, :datetime
      t.string :unlock_token, :string
    end
    add_index :users, :unlock_token, unique: true
  end
end
