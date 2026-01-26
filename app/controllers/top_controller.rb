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
      format.html
      format.turbo_stream { render "shared/load_more" }
    end
  end

  private
    def prepare_viewing_context
      @city = viewing_city
      set_active_character(@city)
    end
end
