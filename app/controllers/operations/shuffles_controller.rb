module Operations
  class ShufflesController < ApplicationController
    include CharacterSessionManageable

    def create
      old_city = viewing_city
      new_city = transition_to_city(exclude_city: old_city)
      # root_pathにするか未定
      if new_city
        redirect_to city_path(new_city), status: :see_other
      else
        redirect_to root_path, status: :see_other
      end
    end
  end
end
