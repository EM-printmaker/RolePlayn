class World < ApplicationRecord
  has_many :cities, dependent: :restrict_with_error
  has_one_attached :image
end
