class ObservationsController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  def show
    @world = World.find_by!(slug: params[:world_slug])
    @city = @world.cities.find_by!(slug: params[:city_slug])
    @observed_subject = Character.find(params[:subject_id])
    posts_scope = @city.feed_posts.where(character_id: @observed_subject.id)

    paginate_posts(posts_scope)

    @post = Post.new

    render "cities/show"
  end

  def load_more
    @world = World.find_by!(slug: params[:world_slug])
    @city = @world.cities.find_by!(slug: params[:city_slug])
    @observed_subject = Character.find(params[:subject_id])

    posts_scope = @city.feed_posts.where(character_id: @observed_subject.id)

    paginate_posts(posts_scope)

    respond_to do |format|
      format.any(:html, :turbo_stream) do
        render "shared/load_more", formats: [ :turbo_stream ], content_type: "text/vnd.turbo-stream.html"
      end
    end
  end
end
