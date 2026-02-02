module Operations
  class ExpressionsController < ApplicationController
      include CharacterSessionManageable

    def create
      if current_character && params[:expression_id].present?
        target_expression = current_character.expressions.find_by(id: params[:expression_id])
        if target_expression
          update_active_expression(target_expression)
        end
      end

      redirect_back fallback_location: root_path
    end
  end
end
