require 'rails_helper'

RSpec.describe "Posts", type: :request do
  describe "POST /posts" do
    let(:world) { create(:world) }
    let(:city) { create(:city, world: world) }
    let(:character) { create(:character, city: city) }
    let!(:expression) { create(:expression, :with_image, character: character) }

    let(:valid_post_params) do
      { post: { content: "テスト投稿です。" } }
    end

    let(:headers) { { "HTTP_REFERER" => city_path(city) } }


    before do
      create(:city, :observer, target_world_id: world.id)
      get world_city_path(world, city)
    end

    it "新しい投稿が作成され、レコード数が1増えること" do
      expect {
        post posts_path, params: valid_post_params, headers: headers
      }.to change(Post, :count).by(1)
    end

    it "正常なレスポンスが返ること" do
      post posts_path, params: valid_post_params, headers: headers
      expect(response).to redirect_to(city_path(city))
      expect(response).to have_http_status(:see_other)
    end

    it "フィードに新しい投稿が追加されること" do
      post posts_path, params: valid_post_params, headers: headers
      follow_redirect!
      expect(response.body).to include("テスト投稿です。")
    end

    it "入力フォームがリセットされること" do
      post posts_path, params: valid_post_params, headers: headers
      follow_redirect!
      expect(response.body).to include('name="post[content]"')
      expect(response.body).not_to include("テスト投稿です。</textarea>")
    end

    it "投稿後に通知がブロードキャストされること" do
      expect {
        post posts_path, params: valid_post_params, headers: headers
      }.to have_broadcasted_to("posts_channel_city_#{city.id}")
    end

    it "作成された投稿のデータ（街・キャラ・表情）が正しいこと" do
      post posts_path, params: valid_post_params, headers: headers
      last_post = Post.last
      expect(last_post.city_id).to eq city.id
      expect(last_post.character_id).to eq character.id
      expect(last_post.expression_id).to eq expression.id
    end

    context "投稿に失敗した場合" do
      let(:invalid_params) { { post: { content: "" }, render_target: "cities/show" } }

      it "レコードが作成されないこと" do
        expect {
          post posts_path, params: invalid_params, headers: headers
        }.not_to change(Post, :count)
      end

      it "エラーメッセージが表示されること" do
        post posts_path, params: invalid_params, headers: headers
        expect(response.body).to include("内容を入力してください")
      end

      it "422 Unprocessable Entity が返り、元のページがレンダリングされること" do
        post posts_path, params: invalid_params, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(city.name)
      end

      it "入力済みの内容を保持したままであること" do
        long_content = "a" * 1001
        post posts_path, params: { post: { content: long_content }, render_target: "cities/show" }, headers: headers
        expect(response.body).to include(long_content)
      end
    end

    context "Turbo Stream 形式でのリクエストの場合" do
      let(:invalid_params) { { post: { content: "" } } }

      it "422ステータスと正しい Turbo Stream レスポンスを返すこと" do
        post posts_path, params: invalid_params, headers: headers, as: :turbo_stream
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
        expect(response.body).to include('turbo-stream action="replace" target="post-form"')
      end
    end

    context "短時間に連続して投稿した場合" do
      it "エラーになること" do
        post posts_path, params: { post: { content: "1回目" }, render_target: "top/index" }, headers: headers
        expect {
          post posts_path,
            params: { post: { content: "2回目" }, render_target: "top/index" },
            headers: headers
        }.not_to change(Post, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /posts/:id" do
    it "レスポンスが Turbo Stream 形式であること"
    it "投稿が削除され、Post レコードが1減ること"
  end
end
