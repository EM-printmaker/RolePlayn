module ExpressionsHelper
  def current_tab
    params[:tab] || "emotions"
  end

  def modal_tab_link(label, tab_name)
    is_active = (current_tab == tab_name)
    params_payload = { tab: tab_name }
    params_payload.merge!(view_type: params[:view_type], view_level: params[:view_level]) if tab_name == "emotions"

    button_to preview_expressions_path,
      params: params_payload,
      method: :post,
      class: "nav-link #{'active' if is_active} border-0 bg-transparent",
      form_class: "d-inline" do
      label
    end
  end

  def character_button_params(character)
    {
      character_id: character.id,
      tab: current_tab,
      view_type: params[:view_type],
      view_level: params[:view_level]
    }
  end

  def emotion_types_for_toggle
    Expression.emotion_types.keys
  end

  def expression_button_config(expression)
    is_active = current_expression&.id == expression.id

    {
      params: {
        expression_id: expression.id,
        tab: current_tab,
        view_type: params[:view_type],
        view_level: params[:view_level]
      },
      active_class: is_active ? "border border-primary border-3" : "border border-transparent",
      data: {
        turbo_method: :post,
        turbo_frame: "_top",
        action: "click->modal#close"
      }
    }
  end

  def emotion_button_config(type)
    current_type = params[:view_type]
    current_level = (current_type == type.to_s) ? params[:view_level].to_i : 0
    new_level = (current_level + 1) % 3

    is_active = (current_type == type.to_s && params[:view_level].to_i > 0)
    active_class = is_active ? "btn-secondary text-white" : "btn-outline-secondary"

    {
      params: {
        view_type: type,
        view_level: new_level,
        tab: "emotions"
      },
      class: "btn #{active_class} px-3 py-2 transition-all",
      data: { turbo_stream: true }
    }
  end

  private
    def emotion_icon(type, options = {})
      color = case type.to_sym
      when :joy   then "text--joy"
      when :angry then "text--angry"
      when :sad   then "text--sad"
      when :fun   then "text--fun"
      when :normal then "text-normal"
      end

      d_attr = case type.to_sym
      when :joy
        "M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16M7 6.5C7 7.328 6.552 8 6 8s-1-.672-1-1.5S5.448 5 6 5s1 .672 1 1.5M4.285 9.567a.5.5 0 0 1 .683.183A3.5 3.5 0 0 0 8 11.5a3.5 3.5 0 0 0 3.032-1.75.5.5 0 1 1 .866.5A4.5 4.5 0 0 1 8 12.5a4.5 4.5 0 0 1-3.898-2.25.5.5 0 0 1 .183-.683M10 8c-.552 0-1-.672-1-1.5S9.448 5 10 5s1 .672 1 1.5S10.552 8 10 8"
      when :angry
        "M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16M4.053 4.276a.5.5 0 0 1 .67-.223l2 1a.5.5 0 0 1 .166.76c.071.206.111.44.111.687C7 7.328 6.552 8 6 8s-1-.672-1-1.5c0-.408.109-.778.285-1.049l-1.009-.504a.5.5 0 0 1-.223-.67zm.232 8.157a.5.5 0 0 1-.183-.683A4.5 4.5 0 0 1 8 9.5a4.5 4.5 0 0 1 3.898 2.25.5.5 0 1 1-.866.5A3.5 3.5 0 0 0 8 10.5a3.5 3.5 0 0 0-3.032 1.75.5.5 0 0 1-.683.183M10 8c-.552 0-1-.672-1-1.5 0-.247.04-.48.11-.686a.502.502 0 0 1 .166-.761l2-1a.5.5 0 1 1 .448.894l-1.009.504c.176.27.285.64.285 1.049 0 .828-.448 1.5-1 1.5"
      when :sad
        "M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0M9.5 3.5a.5.5 0 0 0 .5.5c.838 0 1.65.416 2.053 1.224a.5.5 0 1 0 .894-.448C12.351 3.584 11.162 3 10 3a.5.5 0 0 0-.5.5M7 6.5C7 5.672 6.552 5 6 5s-1 .672-1 1.5S5.448 8 6 8s1-.672 1-1.5M4.5 13c.828 0 1.5-.746 1.5-1.667 0-.706-.882-2.29-1.294-2.99a.238.238 0 0 0-.412 0C3.882 9.044 3 10.628 3 11.334 3 12.253 3.672 13 4.5 13M8 11.197c.916 0 1.607.408 2.25.826.212.138.424-.069.282-.277-.564-.83-1.558-2.049-2.532-2.049-.53 0-1.066.361-1.536.824q.126.27.232.535.069.174.135.373A3.1 3.1 0 0 1 8 11.197M10 8c.552 0 1-.672 1-1.5S10.552 5 10 5s-1 .672-1 1.5S9.448 8 10 8M6.5 3c-1.162 0-2.35.584-2.947 1.776a.5.5 0 1 0 .894.448C4.851 4.416 5.662 4 6.5 4a.5.5 0 0 0 0-1"
      when :fun
        "M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16M7 6.5c0 .501-.164.396-.415.235C6.42 6.629 6.218 6.5 6 6.5s-.42.13-.585.235C5.164 6.896 5 7 5 6.5 5 5.672 5.448 5 6 5s1 .672 1 1.5m5.331 3a1 1 0 0 1 0 1A5 5 0 0 1 8 13a5 5 0 0 1-4.33-2.5A1 1 0 0 1 4.535 9h6.93a1 1 0 0 1 .866.5m-1.746-2.765C10.42 6.629 10.218 6.5 10 6.5s-.42.13-.585.235C9.164 6.896 9 7 9 6.5c0-.828.448-1.5 1-1.5s1 .672 1 1.5c0 .501-.164.396-.415.235"
      when :normal
        "M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16M7 6.5C7 7.328 6.552 8 6 8s-1-.672-1-1.5S5.448 5 6 5s1 .672 1 1.5m-3 4a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7a.5.5 0 0 1-.5-.5M10 8c-.552 0-1-.672-1-1.5S9.448 5 10 5s1 .672 1 1.5S10.552 8 10 8"
      end

      content_tag(:svg,
              tag.path(d: d_attr),
              xmlns: "http://www.w3.org/2000/svg",
              width: options[:size] || "24",
              height: options[:size] || "24",
              fill: "currentColor",
              class: "bi #{options[:class]} #{color}",
              viewBox: "0 0 16 16")
    end
end
