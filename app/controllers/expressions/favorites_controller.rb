module Expressions
  class FavoritesController < ::FavoritesController
    private
    def set_favoritable
      @favoritable = Expression.find(params[:expression_id])
    end
  end
end
