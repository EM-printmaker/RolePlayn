class AddSuspendedReasonToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :suspended_reason, :text
  end
end
