require 'rails_helper'

RSpec.describe "Worlds", type: :request do
  describe "GET /worlds" do
    it "正常なレスポンスが返ること"
    it "全世界を観測する街(node00)へリダイレクトされること"
  end

  describe "GET /:slug" do
    it "正常なレスポンスが返ること"
    it "ワールドを観測する街(node)へリダイレクトされること"

    context "ワールドを観測する街(node)がなく、Slugのワールドに所属する街が存在する場合" do
      it "その世界内の最初の街へリダイレクトされること"
    end

    context "存在しないWorldスラッグの場合" do
      it "404 Not Found が返ること"
    end

    context "世界に属する街が存在しない場合" do
      it "404 Not Foundが返ること"
    end
  end
end
