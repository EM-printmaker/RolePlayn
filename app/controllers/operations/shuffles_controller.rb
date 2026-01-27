module Operations
  class ShufflesController < ApplicationController
    include CharacterSessionManageable

    def create
      transition_to_city
      @city = viewing_city
      # root_pathにするか未定
      redirect_to city_path(@city), status: :see_other
    end
  end
end
