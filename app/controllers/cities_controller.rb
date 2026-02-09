class CitiesController < ApplicationController
  include CharacterSessionManageable
  include FavoriteLookup
  include PostPaginatable

  before_action :prepare_viewing_context, only: [ :show ]
  before_action :set_city_only, only: [ :load_more ]
  before_action :prepare_favorite_ids, only: [ :show, :load_more ]

  def index
    redirect_to city_path(City.global_observer), status: :found
  end

  def show
    paginate_posts(@city.feed_posts.latest.with_details)
    @post = Post.new
  end

  def load_more
    paginate_posts(@city.feed_posts.latest.with_details)
    respond_to do |format|
      format.any(:html, :turbo_stream) do
        render "shared/load_more", formats: [ :turbo_stream ], content_type: "text/vnd.turbo-stream.html"
      end
    end
  end

  private
    def prepare_viewing_context
      set_city_only
      ensure_viewing_setup
    end

    def set_city_only
      @world = World.find_by!(slug: params[:world_slug])
      @city = @world.cities.find_by!(slug: params[:slug])

      session[:viewing_city_id] = @city.id
    end
end
