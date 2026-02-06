class CreateInquiries < ActiveRecord::Migration[7.2]
  def change
    create_table :inquiries do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :message, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
