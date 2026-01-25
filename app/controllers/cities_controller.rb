class CitiesController < ApplicationController
  include CharacterSessionManageable

  def show
    @city = viewing_city
    set_active_character(@city)
    @posts = @city.posts.includes(:character, :expression).order(created_at: :desc)
    @post = Post.new
  end

  def shuffle
    transition_to_city
    @city = viewing_city
    redirect_to city_path(viewing_city)
  end

  def re_roll
    refresh_character(viewing_city)
    redirect_back fallback_location: root_path
  end
end
