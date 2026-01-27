module ApplicationHelper
  def session_token(session_id)
    salt = Time.zone.now.strftime("%Y-%m-%d")
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, "#{session_id}#{salt}")
  end

  def infinite_scroll_load_more_url(pagy, city = nil)
    path =
      if city.present?
        load_more_city_path(city)
      else
        load_more_top_path
      end

    "#{path}?page=#{pagy.next}"
  end
end
