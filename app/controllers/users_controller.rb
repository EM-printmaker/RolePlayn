class UsersController < ApplicationController
  include CharacterSessionManageable
  include FavoriteLookup
  include PostPaginatable

  before_action :prepare_viewing_context
  before_action :authenticate_user!
  before_action :prepare_favorite_ids, only: [ :show, :load_more ]

  def show
    @tab = "posts"
    prepare_posts_data
    respond_to do |format|
      format.html
    end
  end

  def favorited_posts
    @tab = "favorites"
    prepare_posts_data
    respond_to do |format|
      format.html { render :show }
    end
  end

  def load_more
    @tab = params[:tab]
    prepare_posts_data

    respond_to do |format|
      format.any(:html, :turbo_stream) do
        render "shared/load_more", formats: [ :turbo_stream ], content_type: "text/vnd.turbo-stream.html"
      end
    end
  end

  private
    def prepare_viewing_context
      ensure_viewing_setup
      @city = City.find_by(id: params[:city_id]) || viewing_city
    end

    def prepare_posts_data
      base_scope = (@tab == "favorites") ? current_user.favorited_posts : current_user.posts

      @posts = base_scope.latest.with_details
      @posts = @posts.where(city_id: params[:city_id]) if params[:city_id].present?

      paginate_posts(@posts)
      @post = Post.new
    end
end
