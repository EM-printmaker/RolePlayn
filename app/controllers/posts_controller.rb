class PostsController < ApplicationController
  include CharacterSessionManageable

  def create
    @post = Post.new(post_params)
    respond_to do |format|
      if @post.save
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path }
      else
        format.turbo_stream { render :create }
        format.html {
        redirect_back fallback_location: root_path, status: :unprocessable_entity
        }
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
end
