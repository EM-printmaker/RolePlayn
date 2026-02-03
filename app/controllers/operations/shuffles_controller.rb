module Operations
  class ShufflesController < ApplicationController
    include CharacterSessionManageable

    def create
      old_city = viewing_city
      transition_to_city(exclude_city: old_city)
      redirect_to root_path, status: :see_other
    end
  end
end
