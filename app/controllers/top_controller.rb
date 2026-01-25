class TopController < ApplicationController
  include CharacterSessionManageable
  def index
    @city = viewing_city
    set_active_character(@city)
    @posts = @city.posts.includes(:character).order(created_at: :desc)
    @post = Post.new
  end
end
