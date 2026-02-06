module Operations
  class ShufflesController < ApplicationController
    include CharacterSessionManageable

    def create
      old_city = viewing_city
      transition_to_city(exclude_city: old_city)
      if request.referer&.include?(profile_path)
        redirect_to profile_path, status: :see_other
      else
        redirect_to root_path, status: :see_other
      end
    end
  end
end
