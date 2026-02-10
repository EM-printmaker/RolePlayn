require 'rails_helper'

RSpec.describe "Rack::Attack", type: :request do
  let(:remote_ip) { "1.2.3.4" }
  let(:limit) { 10 }

  before do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  after do
    Rack::Attack.enabled = false
  end

  describe "投稿の連打制限" do
    it "制限回数を超えると 429 Too Many Requests を返す" do
      limit.times do
        post posts_path,
          params: { post: { content: "test" } },
          headers: { "REMOTE_ADDR" => remote_ip }

        expect(response).to have_http_status(:found)
      end

      post posts_path,
        params: { post: { content: "over limit" } },
        headers: { "REMOTE_ADDR" => remote_ip }

      expect(response).to have_http_status(:too_many_requests)
    end
  end
end
