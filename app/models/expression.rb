class Expression < ApplicationRecord
  belongs_to :character
  has_many :posts, dependent: :restrict_with_error
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [ 400, 400 ]
  end

  enum :emotion_type, { joy: 0, angry: 1, sad: 2, fun: 3, normal: 4 }

  include RandomSelectable
end
