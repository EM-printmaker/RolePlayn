require 'rails_helper'

RSpec.describe "Cities", type: :request do
  describe "GET /cities" do
    it "正常なレスポンスが返ること"
    it "全都市の投稿を表示する都市へリダイレクトされること"

    context "表示可能な都市が1つもない場合" do
      it "エラーページへリダイレクトされること"
    end
  end

  describe "GET /:world_slug/:slug" do
    it "正常なレスポンスが返ること"
    it "街の名前が含まれていること"
    it "キャラクターの名前が含まれていること"
    it "投稿の内容が含まれていること"
    it "表情の画像が正しく表示されていること"
    xit "アクセスした街がセッション(viewing_city_id)に保存されること"
    xit "その街に所属するキャラクターがセッション(active_character_id)にセットされること"

    context "街の所属する世界がis_global:trueの場合" do
      it "ターゲットにしている世界所属の街すべてのキャラクターが含まれていること"
      it "ターゲットにしている世界所属の街すべての投稿が含まれていること"
    end

    context "街の所属する世界がis_global:falseの場合" do
      it "他の街のキャラクターが含まれていないこと"
    end

    context "存在する街だが、URLのワールドスラッグと所属が一致しない場合" do
      it "404 Not Found が返ること"
    end

    context "街に投稿が1つもない場合" do
      it "「投稿はまだありません」のメッセージが表示されること"
    end

    context "キャラクターが未作成の場合" do
      it "サイドナビに「キャラクターを作成」ボタンが表示されること"
    end
  end

  describe "GET /:world_slug/:slug/load_more" do
    it "Turbo Stream形式で2ページ目のコンテンツを返すこと"
    it "2ページ目の読み込みで、重複しない投稿が返ってくること"
    it "2ページ目の読み込みで、URLが現在の街と一致していること"
    it "最後のページで、「すべての投稿を読み込みました」の表示が返ること"

    context "存在しないページ番号を指定した場合" do
      it "エラーにならず、空のコンテンツが返ること"
    end
  end
end
