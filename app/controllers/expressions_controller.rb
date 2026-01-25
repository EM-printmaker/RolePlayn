class ExpressionsController < ApplicationController
    include CharacterSessionManageable

  def change_face
    if current_character && params[:expression_id].present?
      if current_character.expressions.exists?(params[:expression_id])
        session[:active_expression_id] = params[:expression_id]
        remove_instance_variable(:@current_expression) if defined?(@current_expression)
      end
    end

    redirect_back fallback_location: root_path
  end
end
