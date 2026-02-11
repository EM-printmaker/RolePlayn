module FavoriteLookup
  extend ActiveSupport::Concern

  included do
    helper_method :post_favorited?, :expression_favorited?
  end

  private

  def prepare_favorite_ids
    return unless user_signed_in?

    @_favorited_post_ids = current_user.post_favorites.pluck(:post_id).to_set
    @_favorited_expression_ids = current_user.expression_favorites.pluck(:expression_id).to_set
  end

  def post_favorited?(post)
    return false if post.nil? || !user_signed_in?

    if @_favorited_post_ids
      @_favorited_post_ids.include?(post.id)
    else
      current_user.post_favorites.exists?(post_id: post.id)
    end
  end

  def expression_favorited?(expression)
    return false if expression.nil? || !user_signed_in?

    if @_favorited_expression_ids
      @_favorited_expression_ids.include?(expression.id)
    else
      current_user.expression_favorites.exists?(expression_id: expression.id)
    end
  end
end
