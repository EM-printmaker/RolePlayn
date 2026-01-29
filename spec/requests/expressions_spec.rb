require 'rails_helper'

RSpec.describe "Expressions", type: :request do
  describe "POST expressions/preview" do
    it "正常なレスポンスが返ること"
    it "Turbo Stream形式でモーダルの内容が返ってくること"

    context "表情データが見つからない場合" do
      it "エラーにならないこと"
    end
  end
end
