module IconHelper
  include EmotionIconData
  include SystemIconData

  def emotion_icon(type, options = {})
    data = EMOTION_DATA[type.to_sym]
    return nil unless data

    css_class = "bi #{options[:class]} #{data[:color]}"
    size = options[:size] || "24"

    render_base_svg(data[:path], css_class, size)
  end

  def favorite_icon(favoritable, is_on: false, **options)
    if favoritable.is_a?(Post)
      path = is_on ? FAVORITE_DATA[:post_on][:path] : FAVORITE_DATA[:post_off][:path]
      color = is_on ? "text-primary" : "text-secondary"
    else
      path = is_on ? FAVORITE_DATA[:expression_on][:path] : FAVORITE_DATA[:expression_off][:path]
      color = is_on ? "text-danger" : "text-secondary"
    end

    css_class = "bi #{options[:class]} #{color}"
    size = options[:size] || "20"

    render_base_svg(path, css_class, size)
  end

  private

    def render_base_svg(path, css_class, size)
      content_tag(:svg,
        tag.path(d: path),
        xmlns: "http://www.w3.org/2000/svg",
        width: size,
        height: size,
        fill: "currentColor",
        class: css_class,
        viewBox: "0 0 16 16"
      )
    end
end
