module Posts
  class FavoritesController < ::FavoritesController
    private
    def set_favoritable
      @favoritable = Post.find(params[:post_id])
    end
  end
end
