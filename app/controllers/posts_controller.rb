class PostsController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  def create
    @post =
      if user_signed_in?
        current_user.posts.build(post_params)
      else
        Post.new(post_params)
      end
    @city = viewing_city
    return redirect_to root_path, alert: t(".city_not_found") if @city.nil?
    @post.city_id = @city.id
    @post.character_id = current_character&.id
    @post.expression_id = current_expression&.id
    @post.sender_session_token = helpers.session_token(session.id)
    if @post.save
      redirect_back fallback_location: root_path, status: :see_other
    else
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_content }
        format.html { redirect_to root_path, alert: t(".failure") }
      end
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy!

    redirect_back fallback_location: root_path, status: :see_other
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end
end
