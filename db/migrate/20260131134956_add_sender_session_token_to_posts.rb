class AddSenderSessionTokenToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :sender_session_token, :string
    add_index :posts, :sender_session_token
  end
end
