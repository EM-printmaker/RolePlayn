class Expression < ApplicationRecord
  include RandomSelectable

  belongs_to :character, inverse_of: :expressions
  has_many :posts, dependent: :restrict_with_error, inverse_of: :expression
  has_many :character_assignments, dependent: :destroy
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [ 400, 400 ]
  end

  enum :emotion_type, { joy: 0, angry: 1, sad: 2, fun: 3, normal: 4 }

  scope :with_attached_images, -> {
    includes(image_attachment: { blob: { variant_records: { image_attachment: :blob } } })
  }
end
