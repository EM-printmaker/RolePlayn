# ゲストユーザーのキャラクター抽選をセッションで保持・管理する。
# ログインユーザーはCharacterAssignmentを介して保存・管理する。
module CharacterSessionManageable
  extend ActiveSupport::Concern

  included do
    before_action :set_modal_expression, if: -> { params[:tab] == "emotions" }
    helper_method :current_character, :current_expression, :viewing_city, :characters, :current_favorite_expressions
  end

  # 場所(City)の管理
  def viewing_city
    return @city if @city

    @viewing_city ||= begin
      city = find_city_from_params

      if city.nil?
        city = find_city_from_session
        if city&.global? && params[:slug].blank? && params[:city_id].blank?
          city = find_last_local_city || nil
        end
      end

      city
    end
  end

  def ensure_viewing_setup
    city = viewing_city

    if city.nil? || !assigned_today?(city)
      if city.nil?
        city = transition_to_city
      else
        ensure_assignment(city)
      end
    end

    session[:viewing_city_id] = city.id if city
    session[:last_local_city_id] = city.id if city&.local?
    @viewing_city = city
  end

  def transition_to_city(target_city = nil, exclude_city: nil)
    @city = target_city || City.local.other_than(exclude_city).pick_random || City.local.pick_random

    if @city
      session[:viewing_city_id] = @city.id
      ensure_assignment(@city)
    else
      session.delete(:viewing_city_id)
    end
    @city
  end

  # 配役（Character/Expression）の管理
  def current_character(city = viewing_city)
    return nil if city.blank?

    @current_character ||= {}
    return @current_character[city.id] if @current_character.key?(city.id)

    @current_character[city.id] =
    if user_signed_in?
      fetch_db_assignment(city)&.character
    else
      fetch_session_assignment(city)&.dig(:character)
    end
  end

  def current_expression(city = viewing_city)
    return nil if city.blank?

    @current_expression ||= {}
    return @current_expression[city.id] if @current_expression.key?(city.id)

    @current_expression[city.id] =
    if user_signed_in?
      fetch_db_assignment(city)&.expression
    else
      fetch_session_assignment(city)&.dig(:expression)
    end
  end

  def characters
    @_characters ||= viewing_city.characters.includes(:expressions)
  end


  def current_favorite_expressions(city = viewing_city)
    character = current_character(city)
    return Expression.none if character.blank? || !user_signed_in?

    @current_favorite_expressions ||= {}
    @current_favorite_expressions["#{city.id}_#{character.id}"] ||=
      current_user.favorite_expressions
                  .where(character_id: character.id)
                  .with_attached_image
  end

  # operations/re_rolls
  def refresh_character(city)
    return if city.blank?

    if user_signed_in?
      assignment = CharacterAssignment.ensure_for_today!(current_user, city)
      assignment&.shuffle!
    else
      character, expression = city.pick_random_character_with_expression(exclude: current_character(city))
      update_session_assignment(city, character, expression) if character
    end

    @database_assignment = {}
    @current_character = {}
    @current_expression = {}
  end

  # operations/expressions
  def update_active_expression(expression, city = viewing_city)
    return if expression.blank? || city.blank?

    if user_signed_in?
      fetch_db_assignment(city)&.change_expression!(expression)
    else
      session[:guest_assignments] ||= {}
      if session[:guest_assignments][city.id.to_s]
        session[:guest_assignments][city.id.to_s]["expression_id"] = expression.id
      end
    end

    @current_expression ||= {}
    @current_expression[city.id] = expression
  end

  # ログイン時
  def transfer_guest_assignments_to_db
    return unless user_signed_in? && session[:guest_assignments].present?

    CharacterAssignment.transfer_from_guest!(current_user, session[:guest_assignments])

    session.delete(:guest_assignments)
    reset_character_caches
  end

  def update_active_character(new_character, city = viewing_city)
    return if new_character.blank? || city.blank?

    assignment = CharacterAssignment.ensure_for_today!(current_user, city)
    assignment.switch_character!(new_character)

    reset_character_caches
  end

  private

    # 共通
    def ensure_assignment(city)
      return if city.blank?
      if user_signed_in?
        CharacterAssignment.ensure_for_today!(current_user, city)
      else
        ensure_session_assignment(city)
      end
    end

    # ログインユーザー
    def fetch_db_assignment(city)
      return nil if city.blank? || current_user.nil?
      @database_assignment ||= {}
      @database_assignment[city.id] ||= CharacterAssignment.for_viewing(current_user, city)
    end

    # ゲストユーザー
    def ensure_session_assignment(city)
      if fetch_session_assignment(city).nil?
        raw_data = session.dig(:guest_assignments, city.id.to_s)
        old_character_id = raw_data&.dig("character_id")
        old_character = Character.find_by(id: old_character_id)

        character, expression = city.pick_random_character_with_expression(exclude: old_character)
        update_session_assignment(city, character, expression) if character
      end
    end

    def fetch_session_assignment(city)
      return nil if city.blank? || session[:guest_assignments].nil?

      data = session.dig(:guest_assignments, city.id.to_s)
      return nil if data.nil? || data["assigned_date"] != Time.zone.today.to_s

      {
        character: Character.includes(:expressions).find_by(id: data["character_id"]),
        expression: Expression.with_attached_images.find_by(id: data["expression_id"])
      }
    end

    def update_session_assignment(city, character, expression)
      session[:guest_assignments] ||= {}
      session[:guest_assignments][city.id.to_s] = {
        "character_id" => character&.id,
        "expression_id" => expression&.id,
        "assigned_date" => Time.zone.today.to_s
      }

      @current_character ||= {}
      @current_character[city.id] = character
      @current_expression ||= {}
      @current_expression[city.id] = expression
    end

    def reset_character_caches
      @database_assignment = {}
      @current_character = {}
      @current_expression = {}
    end


    def find_city_from_params
      return nil if params[:city_id].blank?
      City.find_by(slug: params[:city_id]) || City.find_by(id: params[:city_id])
    end

    def find_city_from_session
      City.find_by(id: session[:viewing_city_id])
    end

    def find_last_local_city
      City.find_by(id: session[:last_local_city_id])
    end

    def assigned_today?(city)
      return false if city.blank?

      if user_signed_in?
        CharacterAssignment.exists_for_today?(current_user, city)
      else
        session.dig(:guest_assignments, city.id.to_s, "assigned_date") == Time.zone.today.to_s
      end
    end

    # 表情モーダル
    def set_modal_expression
      character = current_character(viewing_city)
      return if character.nil?

      if params[:view_type].present? && params[:view_level].present?
        @target_expression = character.expressions.find do |e|
          e.emotion_type == params[:view_type] && e.level == params[:view_level].to_i
        end
      end
    end
end
