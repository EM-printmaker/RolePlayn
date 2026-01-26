class CitiesController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  def index
    @city = City.global.first
    @pagy, @posts = pagy(
      Post.from_local_cities.includes(:character, :expression).order(created_at: :desc),
      items: 10
    )
    @post = Post.new
  end

  def show
    @city = City.find(params[:id])
    set_active_character(@city)
    @pagy, @posts = pagy(
      @city.posts.includes(:character, :expression).order(created_at: :desc),
      items: 10
    )
    @post = Post.new
  end

  def shuffle
    transition_to_city
    @city = viewing_city
    redirect_to city_path(viewing_city), status: :see_other
  end

  def re_roll
    refresh_character(viewing_city)
    redirect_back fallback_location: root_path(format: :html), status: :see_other
  end

  def load_more
    paginate_posts(Post.from_local_cities)
  end
end
