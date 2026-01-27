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
end
