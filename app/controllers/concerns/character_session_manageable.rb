module CharacterSessionManageable
  extend ActiveSupport::Concern

  included do
    helper_method :current_character, :current_expression
  end

  def set_active_character(city)
    today = Time.zone.today.to_s
    reset_character_session if session[:assigned_date] != today

    return if session[:active_character_id].present?

    character = city.characters.pick_random
    if character
      expression = character.expressions.pick_random
      session[:active_character_id] = character.id
      session[:active_expression_id] = expression&.id
      session[:assigned_date] = today
    end
  end

  def current_character
    return @current_character if defined?(@current_character)
    @current_character = Character.find_by(id: session[:active_character_id])
  end

  def current_expression
    return @current_expression if defined?(@current_expression)
    @current_expression = Expression.find_by(id: session[:active_expression_id])
  end

  private

    def reset_character_session
      session.delete(:active_character_id)
      session.delete(:active_expression_id)
      session.delete(:assigned_date)
      remove_instance_variable(:@current_character) if defined?(@current_character)
      remove_instance_variable(:@current_expression) if defined?(@current_expression)
    end
end
