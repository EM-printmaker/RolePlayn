class PostFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: { scope: :post_id }


  after_create_commit :notify_post_author

  private

    def notify_post_author
      return unless post&.user
      return if user_id == post.user.id
      post.user.update(unread_notification: true)
    end
end
