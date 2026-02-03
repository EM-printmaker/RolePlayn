class CitiesController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  def index
    redirect_to city_path(City.global_observer), status: :found
  end

  def show
    set_city
    paginate_posts(@city.feed_posts)
    @post = Post.new
  end

  def load_more
    set_city
    paginate_posts(@city.feed_posts)
    respond_to do |format|
      format.any(:html, :turbo_stream) do
        render "shared/load_more", formats: [ :turbo_stream ], content_type: "text/vnd.turbo-stream.html"
      end
    end
  end

  private
    def set_city
      @world = World.find_by!(slug: params[:world_slug])
      @city = @world.cities.find_by!(slug: params[:slug])
      transition_to_city(@city)
    end
end
