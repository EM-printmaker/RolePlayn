module ApplicationHelper
  include Pagy::Frontend
  def session_token(session_id)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, session_id.to_s)
  end

  def infinite_scroll_load_more_url(pagy, city = nil, subject = nil, tab: nil)
    if controller_name == "users"
      params_hash = request.query_parameters.merge(
        page: pagy.next,
        tab: tab
      )
      return load_more_profile_path(params_hash)
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

  def full_title(page_title = "")
    base_title = "RolePlayn"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def hide_sidebar?
    no_sidebar_controllers = %w[inquiries]
    devise_controller? || no_sidebar_controllers.include?(controller_name)
  end

  # ログインモーダル呼び出し用
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
