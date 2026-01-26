class Post < ApplicationRecord
  belongs_to :city
  belongs_to :character
  belongs_to :expression, -> { with_attached_images }, inverse_of: :posts

  validates :content, presence: true, length: { maximum: 300 }

  scope :from_local_worlds, -> { joins(city: :world).merge(World.local) }
  scope :from_world, ->(w_id) { joins(:city).where(cities: { world_id: w_id }) }
  scope :from_city, ->(c_id) { where(city_id: c_id) }

  attr_accessor :sender_session_token
  after_create_commit :broadcast_new_post_notification

  private

    def broadcast_new_post_notification
      broadcast_replace_to(
        "posts_channel",
        target: "new-posts-alert",
        partial: "shared/new_post_notification",
        locals: { sender_session_token: sender_session_token }
      )
    end
end
