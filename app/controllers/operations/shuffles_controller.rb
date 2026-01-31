module Operations
  class ShufflesController < ApplicationController
    include CharacterSessionManageable

    def create
      old_city = viewing_city
      transition_to_city(exclude_city: old_city)
      @city = viewing_city
      # root_pathにするか未定
      redirect_to city_path(@city), status: :see_other
    end
  end
end
