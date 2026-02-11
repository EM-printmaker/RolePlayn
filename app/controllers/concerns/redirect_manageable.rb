module RedirectManageable
  extend ActiveSupport::Concern

  private
    # ---------------------------------------------------------------------------
    # 投稿や削除の際の戻り先を判定する
    # プロフィール画面ならフィルタを維持、それ以外（トップ等）ならフィルタを解除します。
    # ---------------------------------------------------------------------------
    def determine_redirect_path
      uri = URI.parse(request.referer || "")

      referer_path = uri.path&.chomp("/")
      current_profile_path = profile_path.chomp("/")

      if referer_path == current_profile_path
        RedirectUtility.from_referer(request, params)
      else
        RedirectUtility.from_referer_without_city(request, params)
      end
    rescue URI::Error, ArgumentError
      root_path
    end
end
