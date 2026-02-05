class World < ApplicationRecord
  include HasSlug
  include ImageValidatable

  has_many :cities, dependent: :restrict_with_error
  has_many :menu_cities, -> { select(:id, :name, :slug, :world_id) },
    class_name: "City",
    dependent: :restrict_with_error,
    inverse_of: :world

  has_one :observation_city_association, -> { where(target_scope_type: :specific_world) },
    class_name: "City",
    foreign_key: :target_world_id,
    dependent: :nullify,
    inverse_of: :target_world

  has_one_attached :image
  validates_image :image

  validates :name, presence: true, length: { maximum: 50 }
  validates :is_global, inclusion: { in: [ true, false ] }

  scope :global, -> { where(is_global: true)  }
  scope :local,  -> { where(is_global: false) }

  def global?
    is_global
  end

  def local?
    !is_global?
  end

  # Worldのフィードを表示するglobalなCityを返し、nillならglobalな最初のCityを返す
  def observation_city
    observation_city_association || City.global_observer
  end
end
