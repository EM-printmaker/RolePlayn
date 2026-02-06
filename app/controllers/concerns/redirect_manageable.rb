module RedirectManageable
  extend ActiveSupport::Concern

  private

    # ---------------------------------------------------------------------------
    # 安全なリダイレクトURL生成メソッド
    # リファラを解析し、セキュリティチェックを通した上で、city_idパラメータを調整して返します。
    #
    # @param fallback [String] リファラがない/不正な場合の戻り先（デフォルト: root_path）
    # @param new_city_id [Integer, nil, false]
    #   - Integer/String : 指定したIDに city_id を書き換える（例: シャッフル後の移動先）
    #   - nil            : 元の city_id を維持する（例: 投稿失敗時やプロフィール画面での再読み込み）
    #   - false          : city_id を削除する（例: トップページへ戻る時、履歴を汚さないため）
    # ---------------------------------------------------------------------------
    def safe_redirect_url_with_params(fallback: root_path, new_city_id: nil)
      referer = request.referer
      return fallback if referer.blank?

      begin
        uri = URI.parse(referer)
        # javascript: などの危険なスキーム / 外部サイトへのリダイレクト（Open Redirect）を拒否
        return fallback if uri.scheme.present? && %w[http https].exclude?(uri.scheme)
        return fallback if uri.host.present? && uri.host != request.host

        # パラメータ操作:
        query_params = URI.decode_www_form(uri.query || "").to_h
        target_city_id =
          case new_city_id
          when false then nil
          when nil   then query_params["city_id"] || params[:city_id]
          else            new_city_id.to_s
          end

        if target_city_id.present?
          query_params["city_id"] = target_city_id
        else
          query_params.delete("city_id")
        end

        # クエリの再構築（空の場合は nil にして末尾の ? を防ぐ）
        uri.query = query_params.any? ? URI.encode_www_form(query_params) : nil
        # [Security] パスの正規化: //example.com のようなプロトコル相対パス攻撃を防ぐ
        path = (uri.path.presence || "/").gsub(%r{\A/+}, "/")

        uri.query.present? ? "#{path}?#{uri.query}" : path

      rescue URI::InvalidURIError
        # パース不能なURLが来た場合
        fallback
      end
    end

    # ---------------------------------------------------------------------------
    # 投稿や削除の際の戻り先を判定する
    # プロフィール画面ならフィルタを維持、それ以外（トップ等）ならフィルタを解除します。
    # ---------------------------------------------------------------------------
    def determine_redirect_path
      uri = URI.parse(request.referer || "")

      referer_path = uri.path&.chomp("/")
      current_profile_path = profile_path.chomp("/")

      if referer_path == current_profile_path
        safe_redirect_url_with_params
      else
        safe_redirect_url_with_params(new_city_id: false)
      end
    rescue URI::Error, ArgumentError
      root_path
    end

    # ---------------------------------------------------------------------------
    # [ShufflesController用] シャッフル後の移動先決定
    # 街の個別ページにいた場合は新しい街のページへ、それ以外はパラメータ操作で対応します。
    # ---------------------------------------------------------------------------
    def determine_shuffle_redirect_path(new_city)
      begin
        uri = URI.parse(request.referer || "")
        path = uri.path
        recognized = Rails.application.routes.recognize_path(path)
      rescue StandardError
        recognized = {}
      end

      # Namespace を考慮し、末尾が "cities" かつ showアクションかを判定
      controller_name = recognized[:controller].to_s
      is_city_show = controller_name.end_with?("cities") && recognized[:action] == "show"

      if is_city_show
        city_path(new_city)
      elsif path&.chomp("/") == profile_path.chomp("/")
        safe_redirect_url_with_params(new_city_id: new_city.id)
      else
      safe_redirect_url_with_params(new_city_id: false)
      end
    end
end
