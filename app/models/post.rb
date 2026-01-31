class Post < ApplicationRecord
  POST_INTERVAL = 3.seconds.freeze

  belongs_to :city
  belongs_to :character
  belongs_to :expression, -> { with_attached_images }, inverse_of: :posts

  validates :content, presence: true, length: { maximum: 300 }
  validate :post_interval_limit, on: :create

  scope :from_local_worlds, -> { joins(city: :world).merge(World.local) }
  scope :from_world, ->(w_id) { joins(:city).where(cities: { world_id: w_id }) }
  scope :from_city, ->(c_id) { where(city_id: c_id) }

  after_create_commit :broadcast_new_post_notification

  private

    def broadcast_new_post_notification
      broadcast_replace_to(
        "posts_channel_city_#{city_id}",
        target: "new-posts-alert",
        partial: "shared/new_post_notification",
        locals: { sender_session_token: sender_session_token }
      )
    end

    def post_interval_limit
      return if sender_session_token.blank?

      last_post = Post.where(sender_session_token: sender_session_token)
                      .order(created_at: :desc)
                      .first

      if last_post && last_post.created_at > POST_INTERVAL.ago
        wait_time = (POST_INTERVAL - (Time.current - last_post.created_at)).ceil
        errors.add(:base, "あと #{wait_time} 秒でまたお話しできます。")
      end
    end
end
