class TopController < ApplicationController
  include CharacterSessionManageable
  def index
    @city = City.order(:created_at).first
    set_active_character(@city)
    @posts = @city.posts.includes(:character).order(created_at: :desc)
  end
end
