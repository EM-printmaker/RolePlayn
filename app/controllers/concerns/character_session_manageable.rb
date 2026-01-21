module CharacterSessionManageable
  extend ActiveSupport::Concern

  include do
    before_action :set_active_character
  end

  def set_active_character(city)
    return if session[:active_character_id].present?

    character = city.characters.pick_random
    if character
      session[:active_character_id] = character.id

      expression = character.expressions.pick_random
      session[:active_expression_id] = expression&.id
    end
  end

  def current_character
      @current_character ||= Character.find_by(id: session[:active_character_id])
  end
end
