class ExpressionsController < ApplicationController
  include CharacterSessionManageable
  include FavoriteLookup

  before_action :prepare_favorite_ids, only: [ :preview, :favorites ]

  def preview
    @city = viewing_city
    @character = current_character(@city)
    set_modal_expression

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("expression-modal-content", partial: "expressions/modal_inner") }
    end
  end

  def favorites
    @city = viewing_city
    @character = current_character(@city)
    if turbo_frame_request?
      render partial: "expressions/favorites_list", locals: { expressions: current_favorite_expressions }
    end
  end
end
