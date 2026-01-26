class TopController < ApplicationController
  include CharacterSessionManageable
  def index
    @city = viewing_city
    set_active_character(@city)
    @pagy, @posts = pagy(
      Post.from_local_cities.includes(:character, :expression).order(created_at: :desc),
      items: 10
    )
    @post = Post.new
  end
end
