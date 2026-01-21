# ユーザーごとのキャラクター抽選をセッションで保持・管理する。
module CharacterSessionManageable
  extend ActiveSupport::Concern

  included do
    helper_method :current_character, :current_expression
  end

  def set_active_character(city)
    # 0時を回ったタイミングでセッションを切り替える仕様のため
    reset_character_session if session[:assigned_date] != Time.zone.today.to_s

    return if session[:active_character_id].present?
    return if city.blank?

    character_shuffle(city)
  end

  def refresh_character(city)
    reset_character_session
    character_shuffle(city)
  end

  def current_character
    # find_byがnilを返すケース（キャラ削除時など）でもDB再検索を防ぐためdefined?を使用
    return @current_character if defined?(@current_character)
    @current_character = Character.find_by(id: session[:active_character_id])
  end

  def current_expression
    return @current_expression if defined?(@current_expression)
    @current_expression = Expression.find_by(id: session[:active_expression_id])
  end

  private

    def character_shuffle(city)
      character = city.characters.pick_random
      if character
        expression = character.expressions.pick_random
        session[:active_character_id] = character.id
        session[:active_expression_id] = expression&.id
        session[:assigned_date] = Time.zone.today.to_s
      end
    end

    def reset_character_session
      session.delete(:active_character_id)
      session.delete(:active_expression_id)
      session.delete(:assigned_date)

      # defined?によるキャッシュを無効化するため、物理的に変数を削除する必要がある
      remove_instance_variable(:@current_character) if defined?(@current_character)
      remove_instance_variable(:@current_expression) if defined?(@current_expression)
    end
end
