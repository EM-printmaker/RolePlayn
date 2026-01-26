class Post < ApplicationRecord
  belongs_to :city
  belongs_to :character
  belongs_to :expression

  validates :content, presence: true, length: { maximum: 300 }

  scope :from_local_cities, -> { where(city_id: City.local.select(:id)) }

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
