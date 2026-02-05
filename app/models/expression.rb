class Expression < ApplicationRecord
  include RandomSelectable
  include ImageValidatable

  belongs_to :character, inverse_of: :expressions
  has_many :posts, dependent: :restrict_with_error, inverse_of: :expression
  has_many :character_assignments, dependent: :destroy

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [ 400, 400 ]
  end
  validates_image :image

  delegate :city, :world, to: :character, allow_nil: true

  enum :emotion_type, { joy: 0, angry: 1, sad: 2, fun: 3, normal: 4 }

  validates :emotion_type, presence: true
  validates :level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :image, presence: true
  validates :level, uniqueness: {
    scope: [ :character_id, :emotion_type ]
  }

  scope :with_attached_images, -> {
    includes(image_attachment: { blob: { variant_records: { image_attachment: :blob } } })
  }

  # 引数のキャラクターの自身と同じ表情を検索する
  def find_equivalent_for(target_character)
    return nil if target_character.nil?

    found = target_character.expressions.detect { |e| e.emotion_type == emotion_type && e.level == level }
    return found if found

    found = target_character.expressions.detect { |e| e.emotion_type == emotion_type && e.level == 1 }
    return found if found

    target_character.expressions.pick_random || target_character.expressions.first
  end

  # ransack
  def self.ransackable_attributes(_auth_object = nil)
    %w[id emotion_type level character_id created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[character]
  end

  # Avo
  def display_name
    if character.present?
      "#{character&.name} - #{emotion_type} (Lv.#{level})"
    else
      "#{emotion_type} (Lv.#{level})"
    end
  end
end
