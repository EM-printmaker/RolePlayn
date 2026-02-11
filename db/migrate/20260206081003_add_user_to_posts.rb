class AddUserToPosts < ActiveRecord::Migration[7.2]
  def change
    add_reference :posts, :user, null: true, foreign_key: true
  end
end
