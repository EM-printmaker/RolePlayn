class CitiesController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  def index
    target_city = City.global.first
    redirect_to city_path(target_city), status: :found
  end

  def show
    @city = City.find_by!(slug: params[:slug])
    set_active_character(@city)
    paginate_posts(@city.feed_posts)
    @post = Post.new
  end

  def shuffle
    transition_to_city
    @city = viewing_city
    redirect_to city_path(@city), status: :see_other
  end

  def re_roll
    refresh_character(viewing_city)
    redirect_back fallback_location: root_path(format: :html), status: :see_other
  end

  def load_more
    @city = City.find_by!(slug: params[:slug])
    paginate_posts(@city.feed_posts)
    respond_to do |format|
      format.any(:html, :turbo_stream) do
        render "shared/load_more", formats: [ :turbo_stream ], content_type: "text/vnd.turbo-stream.html"
      end
    end
  end
end
