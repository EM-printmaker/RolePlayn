require 'rails_helper'

RSpec.describe "CDN Routing", type: :helper do
  describe "cdn_image_url" do
    let(:expression) { create(:expression, :with_image) }
    let(:mock_cdn_host) { "static.example.com" }

    context "CDN_HOSTが設定されている場合" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CDN_HOST", nil).and_return(mock_cdn_host)
      end

      it "CDNのドメインを含むURLを返すこと" do
        url = helper.cdn_image_url(expression.image)
        expect(url).to start_with("https://#{mock_cdn_host}/")
      end
    end

    context "CDN_HOSTが未設定の場合" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CDN_HOST", nil).and_return(nil)
      end

      it "Rails標準のActive Storageのパスを返すこと" do
        url = helper.cdn_image_url(expression.image)
        expect(url).to include("/rails/active_storage/blobs")
      end
    end
  end
end
