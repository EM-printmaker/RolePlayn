module ApplicationHelper
  include Pagy::Frontend
  def session_token(session_id)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, session_id.to_s)
  end

  def infinite_scroll_load_more_url(pagy, city = nil, subject = nil)
    if controller_name == "users"
      return load_more_profile_path(request.query_parameters.merge(page: pagy.next))
    end

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

  def cdn_image_tag(attachment, options = {})
    return nil unless attachment&.attached?

    variant_name = options.delete(:variant)

    image_source = variant_name ? attachment.variant(variant_name) : attachment

    image_tag cdn_image_url(image_source), options
  end
end
