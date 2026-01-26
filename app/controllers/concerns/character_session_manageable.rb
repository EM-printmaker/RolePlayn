# ユーザーごとのキャラクター抽選をセッションで保持・管理する。
module CharacterSessionManageable
  extend ActiveSupport::Concern

  included do
    before_action :set_modal_expression, if: -> { params[:tab] == "emotions" }
    helper_method :current_character, :current_expression, :viewing_city
  end

  def transition_to_city(target_city = nil)
    @city = target_city || City.local.pick_random

    if @city
      session[:viewing_city_id] = @city.id
      refresh_character(@city)
    else
      session.delete(:viewing_city_id)
    end
    @city
  end

  def viewing_city
    @viewing_city ||= City.find_by(id: session[:viewing_city_id]) || transition_to_city
  end

  def set_active_character(city)
    # 0時を回ったタイミングでセッションを切り替える仕様のため
    reset_character_session if session[:assigned_date] != Time.zone.today.to_s

    return if session[:active_character_id].present? || city.blank?

    character_shuffle(city)
  end

  def refresh_character(city)
    reset_character_session
    character_shuffle(city)
  end

  def current_character
    # find_byがnilを返すケース（キャラ削除時など）でもDB再検索を防ぐためdefined?を使用
    return @current_character if defined?(@current_character)
    @current_character = Character.includes(:expressions).find_by(id: session[:active_character_id])
  end

  def current_expression
    return @current_expression if defined?(@current_expression)

    @current_expression = current_character&.expressions&.find { |e| e.id == session[:active_expression_id].to_i }

    @current_expression ||= Expression.with_attached_images.find_by(id: session[:active_expression_id])
  end

  private

    def character_shuffle(city)
      character = city.characters.pick_random
      return unless character
      expression = character.expressions.pick_random

      if character
        session[:active_character_id] = character.id
        session[:active_expression_id] = expression&.id
        session[:assigned_date] = Time.zone.today.to_s
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
      if params[:view_type].present? && params[:view_level].present?
        @target_expression = current_character.expressions.find do |e|
        e.emotion_type == params[:view_type] &&
        e.level == params[:view_level].to_i
        end
      end
    end
end
