module ExpressionsHelper
  include EmotionIconData
  def modal_tab_button_config(tab_name)
    {
      type: "button",
      class: "nav-link border-0 bg-transparent",
      data: {
        tabs_target: "link",
        tab_name: tab_name,
        action: "click->tabs#change"
      }
    }
  end

  def character_selection_config(character)
    is_active = (character == current_character)

    {
      params: {
        character_id: character.id,
        view_type: params[:view_type],
        view_level: params[:view_level]
      },
      method: :post,
      class: "btn p-0 border-0 flex-shrink-0 text-center shadow-none",
      data: {
        turbo_frame: "character_expression_wrapper",
        action: "click->tabs#submitWithTab"
      },
      is_active: is_active
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
        tab:  params[:tab],
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
end
