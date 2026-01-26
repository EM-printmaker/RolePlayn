class City < ApplicationRecord
  belongs_to :world
  has_many :characters, dependent: :restrict_with_error
  has_many :posts, dependent: :restrict_with_error
  has_one_attached :image

  include RandomSelectable

  scope :global, -> { where(world_id: World.global.select(:id)) }
  scope :local, -> { where(world_id: World.local.select(:id)) }
end
