module Operations
  class ShufflesController < ApplicationController
    include CharacterSessionManageable

    def create
      old_city = viewing_city
      transition_to_city(exclude_city: old_city)
      new_city = @city

      flash[:scroll_to_top] = true
      redirect_to determine_shuffle_redirect_path(new_city), status: :see_other
    end

  private

    def determine_shuffle_redirect_path(new_city)
      begin
        uri = URI.parse(request.referer || "")
        path = uri.path
        recognized = Rails.application.routes.recognize_path(path)
      rescue StandardError
        recognized = {}
      end

      # Namespace を考慮し、末尾が "cities" かつ showアクションかを判定
      controller_name = recognized[:controller].to_s
      is_city_show = controller_name.end_with?("cities") && recognized[:action] == "show"

      if is_city_show
        city_path(new_city)
      elsif path&.chomp("/") == profile_path.chomp("/")
        RedirectUtility.from_referer(request, params, city_id: new_city.id)
      else
        RedirectUtility.from_referer_without_city(request, params)
      end
    end
  end
end
