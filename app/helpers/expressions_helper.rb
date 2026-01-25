module ExpressionsHelper
  def expression_select_link(expression)
    is_active = current_expression&.id == expression.id
    active_class = is_active ? "border border-primary border-3" : "border border-transparent"

    link_to change_face_expressions_path(expression_id: expression.id),
            id: "expression_link_#{expression.id}",
            data: {
              turbo_method: :post,
              action: "click->modal#close"
            },
            class: "expression-item text-decoration-none text-dark" do
      content_tag(:div, class: "rounded #{active_class}") do
        image_tag(cdn_image_url(expression.image.variant(:display)), class: "img-thumbnail")
      end
    end
  end
end
