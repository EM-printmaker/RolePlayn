class AddFeedSettingsToCities < ActiveRecord::Migration[7.2]
  def change
    change_table :cities, bulk: true do |t|
      t.integer :target_scope_type, default: 0
      t.bigint :target_world_id
    end
  add_index :cities, :target_world_id
  end
end
