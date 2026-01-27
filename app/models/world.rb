class World < ApplicationRecord
  include HasSlug

  has_many :cities, dependent: :restrict_with_error
  has_one_attached :image

  scope :global, -> { where(is_global: true)  }
  scope :local,  -> { where(is_global: false) }

  def global?
    is_global
  end

  def local?
    !is_global?
  end

  # Worldのフィードを表示するglobalなCityを返し、nillなら最初のCityを返す
  def observation_city
    City.observer_for(self) || cities.order(:id).first
  end
end
