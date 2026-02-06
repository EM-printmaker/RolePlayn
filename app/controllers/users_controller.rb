class UsersController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  before_action :prepare_viewing_context
  before_action :authenticate_user!

  def show
    @posts = current_user.posts.latest.with_details
    if params[:city_id].present?
      @posts = @posts.where(city_id: params[:city_id])
    end

    paginate_posts(@posts)
    @post = Post.new

    respond_to do |format|
      format.html
    end
  end

  def load_more
    @posts = current_user.posts.latest.with_details
    if params[:city_id].present?
      @posts = @posts.where(city_id: params[:city_id])
    end
    paginate_posts(@posts)

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
end
