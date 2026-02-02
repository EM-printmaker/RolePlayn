class Character < ApplicationRecord
  include RandomSelectable

  belongs_to :city
  has_many :expressions,
    -> { with_attached_images },
    dependent: :destroy,
    inverse_of: :character
  has_many :posts, dependent: :restrict_with_error
  has_many :character_assignments, dependent: :destroy

  delegate :world, to: :city, allow_nil: true

  def primary_observer
    world&.observation_city
  end
end
