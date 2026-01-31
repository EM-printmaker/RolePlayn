module Operations
  class ReRollsController < ApplicationController
    include CharacterSessionManageable

    def create
      refresh_character(viewing_city)
      redirect_back fallback_location: root_path(format: :html), status: :see_other
    end
  end
end
