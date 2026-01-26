class TopController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  def index
    @city = viewing_city
    set_active_character(@city)
    @pagy, @posts = pagy(
      @city.posts.includes(:character, :expression).order(created_at: :desc),
      items: 10
    )
    @post = Post.new
  end

  def load_more
    paginate_posts(Post.from_local_cities)
  end
end
