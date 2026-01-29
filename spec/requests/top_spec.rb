require 'rails_helper'

RSpec.describe "Tops", type: :request do
  it_behaves_like "character_session_manageable", :root_path

  describe "GET root_path" do
    let(:world) { create(:world) }
    let(:city) { create(:city, world: world) }
    let(:character) { create(:character, city: city) }
    let!(:expression) { create(:expression, :with_image, character: character) }
    let!(:post) { create(:post, city: city, character: character, expression: expression) }

    before do
      get root_path
    end

    it "正常なレスポンスが返ること" do
      expect(response).to have_http_status(:success)
    end

    it "街の名前が含まれていること" do
      expect(response.body).to include(city.name)
    end

    it "キャラクターの名前が含まれていること" do
      expect(response.body).to include(character.name)
    end

    it "投稿の内容が含まれていること" do
      expect(response.body).to include(post.content)
    end

    it "表情の画像が正しく表示されていること" do
      filename = expression.image.filename.to_s
      expect(response.body).to include(filename)
    end

    it "新規投稿用のオブジェクトが準備されていること"
    it "表示される投稿が最新順（created_at DESC）であること"

    context "投稿が一件もない場合" do
      it "エラーにならず正常にページが表示されること"
    end
  end

  describe "GET top/load_more" do
    it "Turbo Stream形式で2ページ目のコンテンツを返すこと"
    it "2ページ目の読み込みで、重複しない投稿が返ってくること"
    it "2ページ目の読み込みで、URLが現在の街と一致していること"
    it "最後のページで、「すべての投稿を読み込みました」の表示が返ること"

    context "存在しないページ番号を指定した場合" do
      it "エラーにならず、空のコンテンツが返ること"
    end
  end
end
