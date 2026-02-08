class AddUnreadNotificationToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :unread_notification, :boolean, default: false, null: false
  end
end
