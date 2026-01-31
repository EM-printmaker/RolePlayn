class PostsController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  def create
    @post = Post.new(post_params)
    @city = viewing_city
    return redirect_to root_path, alert: t(".city_not_found") if @city.nil?
    @post.city_id = @city.id
    @post.character_id = current_character&.id
    @post.expression_id = current_expression&.id
    @post.sender_session_token = helpers.session_token(session.id)
    if @post.save
      redirect_back fallback_location: root_path, status: :see_other
    else
      prepare_page_data(params[:render_target])

      respond_to do |format|
        format.turbo_stream { render status: :unprocessable_entity }
        format.html { render params[:render_target] || "top/index", status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end

  private

  def post_params
    params.require(:post).permit(
      :content,
      :city_id,
      :character_id,
      :expression_id
    )
  end

  def prepare_page_data(target)
    case target
    when "cities/show"
      prepare_city_show
    else
      prepare_top_index
    end
  end

  def prepare_city_show
    paginate_posts(@city.feed_posts)
  end

  def prepare_top_index
    paginate_posts(@city.feed_posts)
  end
end
