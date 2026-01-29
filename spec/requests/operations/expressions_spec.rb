require 'rails_helper'

RSpec.describe "Operations::Expressions", type: :request do
  describe "POST /expressions" do
    it "セッションに保存される表情が更新されること"
    it "レスポンスが Turbo Stream 形式であること"
    it "フォームの画像URLが選択した表情で更新されること"
  end
end
