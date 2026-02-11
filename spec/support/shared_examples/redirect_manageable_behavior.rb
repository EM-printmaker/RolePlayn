RSpec.shared_examples "redirect_manageable_behavior" do |method: :post|
  let(:host) { "www.example.com" }
  let(:request_params) { defined?(action_params) ? action_params : {} }

  describe "Security: Open Redirect Protection" do
    # 攻撃パターンの定義
    malicious_urls = [
      "http://evil.com/login",
      "//evil.com",
      "javascript:alert(1)",
      "data:text/html,<script>alert(1)</script>"
    ]

    malicious_urls.each do |malicious_url|
      it "不正なリファラ (#{malicious_url.truncate(20)}) の場合は root_path にフォールバックすること" do
        send(method, action_path, params: request_params, headers: { "HTTP_REFERER" => malicious_url })
        expect(response).to redirect_to("/")
      end
    end
  end

  describe "Logic: Internal Parameter Manipulation" do
    it "内部リファラに応じて適切にパラメータを処理し、期待するパスへリダイレクトすること" do
      # referer_url と expected_path は呼び出し元で let 定義する
      send(method, action_path, params: request_params, headers: { "HTTP_REFERER" => referer_url })
      expect(response).to redirect_to(expected_path)
    end
  end
end
