module Operations
  class ShufflesController < ApplicationController
    include CharacterSessionManageable

    def create
      transition_to_city
      @city = viewing_city
      redirect_to city_path(@city), status: :see_other
    end
  end
end
