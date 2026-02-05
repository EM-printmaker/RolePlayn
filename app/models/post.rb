class Post < ApplicationRecord
  POST_INTERVAL = 3.seconds.freeze

  belongs_to :city
  belongs_to :character
  belongs_to :expression, -> { with_attached_images }, inverse_of: :posts

  validates :content, presence: true, length: { maximum: 300 }
  validates :sender_session_token, presence: true
  validate :character_must_belong_to_city
  validate :expression_must_belong_to_character
  validate :post_interval_limit, on: :create

  scope :from_local_worlds, -> { joins(city: :world).merge(World.local) }
  scope :from_world, ->(w_id) { joins(:city).where(cities: { world_id: w_id }) }
  scope :from_city, ->(c_id) { where(city_id: c_id) }

  scope :with_details, -> {
    includes(:city, character: { city: { world: { observation_city_association: :world } } })
    .preload(
      expression: { image_attachment: { blob: { variant_records: { image_attachment: :blob } } } }
    )
  }

  # after_create_commit :broadcast_new_post_notification

  private

    def broadcast_new_post_notification
      broadcast_replace_to(
        "posts_channel_city_#{city_id}",
        target: "new-posts-alert",
        partial: "shared/new_post_notification",
        locals: { sender_session_token: sender_session_token }
      )
    end

    def character_must_belong_to_city
      return if city_id.blank? || character_id.blank?

      unless character.city_id == city_id
        errors.add(:character, :invalid_city_association)
      end
    end

    def expression_must_belong_to_character
      return if character_id.blank? || expression_id.blank?

      unless expression.character_id == character_id
        errors.add(:expression, :not_owned_by_character)
      end
    end

    def post_interval_limit
      return if sender_session_token.blank?

      last_post = Post.where(sender_session_token: sender_session_token)
                      .order(created_at: :desc)
                      .first

      if last_post && last_post.created_at > POST_INTERVAL.ago
        wait_time = (POST_INTERVAL - (Time.current - last_post.created_at)).ceil
        errors.add(:base, :too_soon, count: wait_time)
      end
    end
end
