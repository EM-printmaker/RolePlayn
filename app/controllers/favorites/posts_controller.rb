module Favorites
  class PostsController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :authenticate_user!
    before_action :set_post

    def create
      current_user.post_favorites.create(post: @post)
      render_turbo_update(true)
    end

    def destroy
      favorite = current_user.post_favorites.find_by(post: @post)
      favorite&.destroy
      render_turbo_update(false)
    end

    private

    def set_post
      @post = Post.find(params[:post_id])
    end

    def render_turbo_update(is_favorited)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@post, :favorite),
            partial: "favorites/post_toggle",
            locals: { post: @post, is_favorited: is_favorited }
          )
        end
      end
    end
  end
end
