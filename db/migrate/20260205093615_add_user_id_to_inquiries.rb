class AddUserIdToInquiries < ActiveRecord::Migration[7.2]
  def change
    add_reference :inquiries, :user, null: true, foreign_key: true
  end
end
