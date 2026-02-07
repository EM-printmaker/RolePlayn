class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_favoritable

  def create
    @favorite = current_user.favorites.create(favoritable: @favoritable)
    render turbo_stream: turbo_stream.replace(
      dom_id(@favoritable, :favorite),
      partial: "favorites/button",
      locals: { favoritable: @favoritable }
    )
  end

  def destroy
    favorite = current_user.favorites.find_by(favoritable: @favoritable)
    favorite&.destroy
    render turbo_stream: turbo_stream.replace(
      dom_id(@favoritable, :favorite),
      partial: "favorites/button",
      locals: { favoritable: @favoritable }
    )
  end

  private

    def set_favoritable
      raise NotImplementedError, "Subclasses must implement set_favoritable"
    end
end
