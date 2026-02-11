class AddDexcriptionToCities < ActiveRecord::Migration[7.2]
  def change
    add_column :cities, :description, :text
  end
end
