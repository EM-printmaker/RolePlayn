module Favorites
  class ExpressionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_expression

    def create
      current_user.expression_favorites.create!(expression: @expression)
      render_turbo_update(true)
    end

    def destroy
      favorite = current_user.expression_favorites.find_by(expression: @expression)
      favorite&.destroy
      render_turbo_update(false)
    end

    private

    def set_expression
      @expression = Expression.find(params[:expression_id])
    end

    def render_turbo_update(is_favorited)
      respond_to do |format|
        format.turbo_stream do
          targets = [ "grid", "list", "preview", "fav" ]

          streams = targets.map do |prefix|
            turbo_stream.replace(
              "fav_exp_#{prefix}_#{@expression.id}",
              partial: "favorites/expression_toggle",
              locals: { expression: @expression, is_favorited: is_favorited, prefix: prefix }
            )
          end
          render turbo_stream: streams
        end
      end
    end
  end
end
