class TopController < ApplicationController
  include CharacterSessionManageable
  def index
    @city = viewing_city
    set_active_character(@city)
    @posts = @city.posts.includes(:character, :expression).order(created_at: :desc)
    @post = Post.new
  end
end
