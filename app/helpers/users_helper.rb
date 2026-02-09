module UsersHelper
  def profile_tab_filter_path(tab, city_id = nil)
    params = { city_id: city_id }.compact

    if tab == "favorites"
      favorited_posts_profile_path(params)
    else
      profile_path(params)
    end
  end
end
