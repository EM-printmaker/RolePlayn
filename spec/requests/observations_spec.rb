require 'rails_helper'

RSpec.describe "Observations", type: :request do
  describe "GET /:world_slug/:city_slug/observations/:subject_id" do
    it "正常なレスポンスが返ること"
    it "街(node)の名前が含まれていること"
    it "投稿に含まれるキャラクターの名前が同じであること"
    it "表情の画像が正しく表示されていること"

    context "存在しないsubject_idを指定した場合" do
      it "存在しないリソースのため、404 Not Found が返ること"
    end

    context "アクセスした街(city_slug)がis_global:true所属の街(node)ではない場合" do
      it "該当するis_global:trueの街にリダイレクトされること"
    end

    context "対象の世界を観測する街(node)が存在しない場合" do
      it "全ての世界の投稿を表示する街(node)で正常に表示されること"
    end

    context "対象キャラクターに投稿が1つもない場合" do
      it "エラーならないこと"
    end
  end

  describe "GET /:world_slug/:city_slug/observations/:subject_id/load_more" do
    it "Turbo Stream形式で2ページ目のコンテンツを返すこと"
    it "2ページ目の読み込みで、重複しない投稿が返ってくること"
    it "2ページ目の読み込みで、URLが現在の街と一致していること"
    it "最後のページで、「すべての投稿を読み込みました」の表示が返ること"

    context "存在しないページ番号を指定した場合" do
      it "エラーにならず、空のコンテンツが返ること"
    end
  end
end
