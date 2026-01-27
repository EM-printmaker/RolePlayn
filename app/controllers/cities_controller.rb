class CitiesController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  def index
    redirect_to city_path(City.global_node), status: :found
  end

  def show
    @city = City.find_by!(slug: params[:slug])
    set_active_character(@city)
    paginate_posts(@city.feed_posts)
    @post = Post.new
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
