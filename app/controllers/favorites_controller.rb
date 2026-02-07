class FavoritesController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :authenticate_user!
  before_action :set_favoritable

  def create
    @favorite = current_user.favorites.create(favoritable: @favoritable)
    render_turbo_replace
  end

  def destroy
    favorite = current_user.favorites.find_by(favoritable: @favoritable)
    favorite&.destroy
    render_turbo_replace
  end

  private

    def set_favoritable
      if params[:expression_id]
        @favoritable = Expression.find(params[:expression_id])
      elsif params[:post_id]
        @favoritable = Post.find(params[:post_id])
      end
    end

    def render_turbo_replace
      respond_to do |format|
        format.turbo_stream do
          if @favoritable.is_a?(Expression)
            render turbo_stream: turbo_stream.replace(
              "fav_exp_#{@favoritable.id}",
              partial: "favorites/expression_toggle",
              locals: { expression: @favoritable }
            )
          else
            render turbo_stream: turbo_stream.replace(
              dom_id(@favoritable, :favorite),
              partial: "favorites/button",
              locals: { favoritable: @favoritable }
            )
          end
        end
      end
    end
end
