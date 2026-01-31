class ObservationsController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  before_action :set_resources
  before_action :ensure_primary_observer, only: [ :show, :load_more ]

  def show
    posts_scope = @city.feed_posts.where(character_id: @observed_subject.id)
    paginate_posts(posts_scope)
    render "cities/show"
  end

  def load_more
    posts_scope = @city.feed_posts.where(character_id: @observed_subject.id)
    paginate_posts(posts_scope)

    respond_to do |format|
      format.any(:html, :turbo_stream) do
        render "shared/load_more", formats: [ :turbo_stream ], content_type: "text/vnd.turbo-stream.html"
      end
    end
  end

  private
    def set_resources
      @world = World.find_by!(slug: params[:world_slug])
      @city = @world.cities.find_by!(slug: params[:city_slug])
      @observed_subject = Character.find(params[:subject_id])
    end

    def ensure_primary_observer
      official = @observed_subject.primary_observer
      return if official.nil? || @city == official
      redirect_to observation_path(@observed_subject), status: :moved_permanently
    end
end
