module Operations
  class CharacterSelectionsController < ApplicationController
    include CharacterSessionManageable
    def create
      target_character = viewing_city.characters.find(params[:character_id])
      update_active_character(target_character)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("expression-modal-content", partial: "expressions/modal_inner"),
            turbo_stream.update("side-nav-container", partial: "shared/side_nav"),
            turbo_stream.update("current_expression", partial: "expressions/current_display")
          ]
        end
      end
    end
  end
end
