class AddReplyDraftToInquiries < ActiveRecord::Migration[7.2]
  def change
    change_table :inquiries, bulk: true do |t|
      t.string :reply_subject
      t.text :reply_body
      t.datetime :reply_sent_at
    end
    add_index :inquiries, :reply_sent_at
  end
end
