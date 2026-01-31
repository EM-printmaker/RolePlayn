class TopController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  before_action :prepare_viewing_context

  def index
    paginate_posts(@city.feed_posts)
    @post = Post.new
  end

  def load_more
    paginate_posts(@city.feed_posts)
    respond_to do |format|
      format.any(:html, :turbo_stream) do
        render "shared/load_more", formats: [ :turbo_stream ], content_type: "text/vnd.turbo-stream.html"
      end
    end
  end

  private
    def prepare_viewing_context
      current_viewing_city = viewing_city
      set_active_character(current_viewing_city)
      @city = viewing_city
    end
end
