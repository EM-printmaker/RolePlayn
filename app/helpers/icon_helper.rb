module IconHelper
  include EmotionIconData
  include SystemIconData

  def nav_icon(type, options = {})
    render_icon_from_source(NAV_DATA, type, "offcanvas__icon", "20", options)
  end

  def emotion_icon(type, options = {})
    render_icon_from_source(EMOTION_DATA, type, "bi", "24", options)
  end

  def system_icon(type, options = {})
    render_icon_from_source(SYSTEM_DATA, type, "system-icon", "24", options)
  end

  def favorite_icon(favoritable, is_on: false, **options)
    if favoritable.is_a?(Post)
      path = is_on ? FAVORITE_DATA[:post_on][:path] : FAVORITE_DATA[:post_off][:path]
      color = is_on ? "favorite__icon--on" : "text-secondary"
    else
      path = is_on ? FAVORITE_DATA[:expression_on][:path] : FAVORITE_DATA[:expression_off][:path]
      color = is_on ? "text-danger" : "text-secondary"
    end

    css_class = "bi #{options[:class]} #{color}"
    size = options[:size] || "20"

    render_base_svg(path, css_class, size)
  end

  private

    def render_base_svg(raw_path_data, css_class, size)
      paths_html = Array(raw_path_data).map do |path_item|
        if path_item.is_a?(Hash)
          tag.path(**path_item)
        else
          tag.path(d: path_item)
        end
      end.join.html_safe

      content_tag(:svg,
        paths_html,
        xmlns: "http://www.w3.org/2000/svg",
        width: size,
        height: size,
        fill: "currentColor",
        class: css_class,
        viewBox: "0 0 16 16"
      )
    end

    def render_icon_from_source(data_source, type, base_class_name, default_size, options)
      data = data_source[type.to_sym]
      return nil unless data

      css_classes = [
        base_class_name,
        data[:color],
        options[:class]
      ].compact.join(" ")

      size = options[:size] || default_size

      render_base_svg(data[:path], css_classes, size)
    end
end
