class PostsController < ApplicationController
  include CharacterSessionManageable

  def create
    @post = Post.new(post_params)
    @post.city_id = viewing_city.id
    @post.character_id = current_character&.id
    @post.expression_id = current_expression&.id
    if @post.save
      redirect_back fallback_location: root_path, status: :see_other
    else
      @city = viewing_city
      @pagy, @posts = pagy(
      Post.from_local_cities.includes(:character, :expression).order(created_at: :desc),
      items: 10
    )
      flash[:error] = @post.errors.full_messages.to_sentence
      redirect_back fallback_location: root_path, status: :see_other
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
