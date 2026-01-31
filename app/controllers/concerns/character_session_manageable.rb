# ユーザーごとのキャラクター抽選をセッションで保持・管理する。
module CharacterSessionManageable
  extend ActiveSupport::Concern

  included do
    before_action :set_modal_expression, if: -> { params[:tab] == "emotions" }
    helper_method :current_character, :current_expression, :viewing_city
  end

  def transition_to_city(target_city = nil, exclude_city: nil)
    if target_city
      @city = target_city
    else
      @city = City.local.other_than(exclude_city).pick_random || City.local.pick_random
    end

    if @city
      session[:viewing_city_id] = @city.id
      @viewing_city = @city
      refresh_character(@city)
    else
      session.delete(:viewing_city_id)
      reset_character_session
    end
    @city
  end

  def viewing_city
    @viewing_city ||= City.find_by(id: session[:viewing_city_id]) || transition_to_city
  end

  def set_active_character(city)
    # 0時を回ったタイミングでセッションを切り替える仕様のため
    if session[:assigned_date] != Time.zone.today.to_s
      rotate_daily_session(city)
      return
    end

    return if session[:active_character_id].present? || city.blank?
    character_shuffle(city)
  end

  def refresh_character(city)
    reset_character_session
    character_shuffle(city)
  end

  def current_character
    return @current_character if defined?(@current_character)

    id = session[:active_character_id]
    if id.blank?
      return @current_character = nil
    end

    @current_character = Character.includes(:expressions).find_by(id: id)

    # 3. IDはあるのにキャラが見つからないとき
    if @current_character.nil?
      reset_character_session
      @current_character = nil
    end

    @current_character
  end

  def current_expression
    return @current_expression if defined?(@current_expression)
    return @current_expression = nil if current_character.nil?

    @current_expression = current_character&.expressions&.find { |e| e.id == session[:active_expression_id].to_i }

    @current_expression ||= Expression.with_attached_images.find_by(id: session[:active_expression_id])
  end

  # 書き換えが発生した時に、古いキャッシュを捨てる
  def reset_active_expression
    remove_instance_variable(:@current_expression) if defined?(@current_expression)
  end

  private

    def rotate_daily_session(old_city)
      old_character_id = session[:active_character_id]
      new_city = transition_to_city
      new_character = current_character

      if new_city.id == old_city.id && new_character&.id == old_character_id
        other_character = new_city.characters.where.not(id: old_character_id).pick_random

        if other_character
          update_session_for_character(other_character)
        else
          transition_to_city(exclude_city: old_city)
        end
      end
    end

    def character_shuffle(city)
      character = city.characters.pick_random
      update_session_for_character(character)
    end

    def update_session_for_character(character)
      expression = character&.expressions&.pick_random

      if character
        session[:active_character_id] = character.id
        session[:active_expression_id] = expression&.id
        session[:assigned_date] = Time.zone.today.to_s
      else
        reset_character_session
      end

      @current_character = character
      @current_expression = expression
    end

    def reset_character_session
      session.delete(:active_character_id)
      session.delete(:active_expression_id)
      session.delete(:assigned_date)

      # defined?によるキャッシュを無効化するため、物理的に変数を削除する必要がある
      remove_instance_variable(:@current_character) if defined?(@current_character)
      remove_instance_variable(:@current_expression) if defined?(@current_expression)
    end

    def set_modal_expression
      return if current_character.nil?

      if params[:view_type].present? && params[:view_level].present?
        @target_expression = current_character.expressions.find do |e|
        e.emotion_type == params[:view_type] &&
        e.level == params[:view_level].to_i
        end
      end
    end
end
