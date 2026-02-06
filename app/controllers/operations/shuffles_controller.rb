module Operations
  class ShufflesController < ApplicationController
    include CharacterSessionManageable
    include RedirectManageable

    def create
      old_city = viewing_city
      transition_to_city(exclude_city: old_city)
      new_city = @city

      redirect_to determine_shuffle_redirect_path(new_city), status: :see_other
    end
  end
end
