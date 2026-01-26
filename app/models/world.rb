class World < ApplicationRecord
  has_many :cities, dependent: :restrict_with_error
  has_one_attached :image

  scope :global, -> { where(is_global: true)  }
  scope :local,  -> { where(is_global: false) }
end
