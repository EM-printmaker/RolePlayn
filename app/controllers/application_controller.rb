class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  include Pagy::Backend
  include CharacterSessionManageable
  include FavoriteLookup

  before_action :set_all_worlds
  before_action :reject_suspended_user
  before_action :basic_auth, if: -> { Rails.env.production? }

  def debug_env
    # 1. Resend APIキーの状態確認
    api_key = ENV["RESEND_API_KEY"]
    key_status = if api_key.blank?
                   "❌ 未設定 (nil または 空文字)"
    elsif api_key.match?(/\s/)
                   "⚠️ 警告: 前後に空白が含まれています！ Renderの設定を確認してください"
    else
                   "✅ OK (値: #{api_key.first(5)}...#{api_key.last(5)})" # セキュリティのため一部だけ表示
    end

    # 2. 送信元アドレスの状態確認
    mail_from = ENV["MAIL_FROM_ADDRESS"]
    from_status = mail_from.present? ? "✅ OK (値: #{mail_from})" : "❌ 未設定"

    # 3. ログ設定の状態確認
    log_stdout = ENV["RAILS_LOG_TO_STDOUT"]
    log_status = log_stdout.present? ? "✅ OK (値: #{log_stdout})" : "❌ 未設定 (これが原因でログが出ない可能性があります)"

    # 画面に表示するメッセージを作成
    render plain: <<~TEXT
      === 環境変数 診断レポート ===

      [1] RESEND_API_KEY
      #{key_status}

      [2] MAIL_FROM_ADDRESS
      #{from_status}

      [3] RAILS_LOG_TO_STDOUT
      #{log_status}

      ===========================
      ※ 確認後はこのコードとルーティングを削除してください。
    TEXT
  end

  private

    def set_all_worlds
      @worlds = World.select(:id, :slug, :name).preload(:menu_cities)
    end

    def after_sign_in_path_for(resource)
      if session[:guest_assignments].present?
        CharacterAssignment.transfer_from_guest!(resource, session[:guest_assignments])
        session.delete(:guest_assignments)
      end

      if resource.sign_in_count == 1 && resource.login_id.blank?
        flash[:notice] = t("flash.sessions.welcome_and_setup_id")
        edit_user_registration_path
      else
        super
      end
    end

    # 凍結管理
    def reject_suspended_user
      if user_signed_in? && current_user.suspended_at.present?
        sign_out current_user
        flash[:alert] = t("custom_errors.messages.account_suspended")
        redirect_to root_path
      end
    end

    def basic_auth
      authenticate_or_request_with_http_basic do |username, password|
      username == ENV["BASIC_AUTH_USER"] &&
      password == ENV["BASIC_AUTH_PASSWORD"]
      end
    end
end
