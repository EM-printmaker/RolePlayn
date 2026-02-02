class ExpressionsController < ApplicationController
  include CharacterSessionManageable

  def preview
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("expression-modal-content", partial: "expressions/modal_inner") }
    end
  end
end
