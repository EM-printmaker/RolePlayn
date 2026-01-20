class City < ApplicationRecord
  belongs_to :world
  has_many :characters, dependent: :restrict_with_error
  has_one_attached :image
end
