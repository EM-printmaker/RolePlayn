module ApplicationHelper
  include Pagy::Frontend
  def session_token(session_id)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, session_id.to_s)
  end

  def infinite_scroll_load_more_url(pagy, city = nil, subject = nil)
    path =
      if subject.present? && city.present?
        load_more_observation_path(city, subject)
      elsif city.present?
        load_more_city_path(city)
      else
        load_more_top_path
      end

    "#{path}?page=#{pagy.next}"
  end
end
