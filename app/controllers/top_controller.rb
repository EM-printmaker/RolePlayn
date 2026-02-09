class TopController < ApplicationController
  include CharacterSessionManageable
  include FavoriteLookup
  include PostPaginatable

  before_action :prepare_viewing_context
  before_action :prepare_favorite_ids, only: [ :index, :load_more ]

  def index
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
      ensure_viewing_setup
      @city = viewing_city
    end
end
