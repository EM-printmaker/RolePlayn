# アプリケーション全体で共通して利用される、安全なリダイレクト先を生成・決定するための主要な窓口となるメソッド群です。
module RedirectUtility
  class << self
    # リファラを元に、安全なリダイレクト先を決定します
    def from_referer(request, params, anchor: nil, city_id: nil)
      orchestrate(request.referer, request, params, anchor, city_id: city_id)
    end

    # 指定URLを元に、安全なリダイレクト先を決定します
    def from_url(url, request, params, anchor: nil, city_id: nil)
      orchestrate(url, request, params, anchor, city_id: city_id)
    end

    # リファラを元に、city_idを削除してリダイレクト先を決定します
    def from_referer_without_city(request, params, anchor: nil)
      orchestrate(request.referer, request, params, anchor, remove_city: true)
    end

    private

      # URLの安全点検、各種加工（クエリ・パス）、整形（文字列化・アンカー結合）を行います
      def orchestrate(raw_url, request, params, anchor, city_id: nil, remove_city: false)
        uri = parse_to_safe_uri(raw_url, request)
        return "/" if uri.nil?

        adjust_city_id!(uri, params, city_id, remove_city)
        strip_load_more_path!(uri)
        assemble_final_url(uri, anchor || params[:scroll_to])
      end

      # 安全性を確認し、URIオブジェクトを生成する
      def parse_to_safe_uri(url_string, request)
        return nil if url_string.blank?
        uri = URI.parse(url_string)

        return nil if uri.scheme.present? && %w[http https].exclude?(uri.scheme)
        return nil if uri.host.present? && uri.host != request.host

        uri.path = (uri.path.presence || "/").gsub(%r{\A/+}, "/")
        uri
      rescue URI::InvalidURIError
        nil
      end

    # city_id パラメータの追加・変更・削除を行う
    def adjust_city_id!(uri, params, forced_id, should_remove)
      query = URI.decode_www_form(uri.query || "").to_h

      if should_remove
        query.delete("city_id")
      else
        query["city_id"] = forced_id&.to_s || query["city_id"] || params[:city_id]
      end

      clean_query = query.compact_blank
      uri.query = clean_query.any? ? URI.encode_www_form(clean_query) : nil
    end

    # パスから /load_more を取り除く
    def strip_load_more_path!(uri)
      return unless uri.path&.include?("load_more")
      uri.path = uri.path.gsub("/load_more", "").gsub(%r{\A/+}, "/")
    end

    # 最終的な文字列を構築する
    def assemble_final_url(uri, anchor)
      base_url = uri.to_s
      anchor.present? ? "#{base_url.split('#').first}##{anchor}" : base_url
    end
  end
end
