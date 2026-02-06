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

  validates :name, presence: true, length: { maximum: 50 }


  def primary_observer
    world&.observation_city
  end

  def main_image
    target = expressions.find { |e| e.normal? && e.level == 1 }
    target ||= expressions.min_by(&:id)
    target&.image
  end

  def match_expression(template_expression)
    template_expression&.find_equivalent_for(self) || expressions.pick_random
  end

  # ransack
  def self.ransackable_attributes(_auth_object = nil)
    %w[id name city_id created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[city]
  end
end
