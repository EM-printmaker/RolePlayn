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

    def perform_post(overrides = {})
      post posts_path,
        params: valid_post_params.merge(overrides),
        headers: headers,
        as: :turbo_stream
    end

    before do
      create(:city, :observer, target_world_id: world.id)
      get root_path
    end

    it "新しい投稿が作成され、レコード数が1増えること" do
      expect {
        perform_post
      }.to change(Post, :count).by(1)
    end

    it "正常なレスポンスが返ること" do
      perform_post
      expect(response).to redirect_to(city_path(city))
      expect(response).to have_http_status(:see_other)
    end

    it "フィードに新しい投稿が追加されること" do
      perform_post
      follow_redirect!
      expect(response.body).to include("テスト投稿です。")
    end

    it "入力フォームがリセットされること" do
      perform_post
      follow_redirect!
      expect(response.body).to include('name="post[content]"')
      expect(response.body).not_to include("テスト投稿です。</textarea>")
    end

    it "投稿後に通知がブロードキャストされること" do
      skip "ブロードキャスト一時停止中のため"
      expect {
        perform_post
      }.to have_broadcasted_to("posts_channel_city_#{city.id}")
    end

    it "作成された投稿のデータ（街・キャラ・表情）が正しいこと" do
      perform_post
      last_post = Post.last
      expect(last_post.city_id).to eq city.id
      expect(last_post.character_id).to eq character.id
      expect(last_post.expression_id).to eq expression.id
    end

    context "投稿に失敗した場合" do
      let(:invalid_params) { { post: { content: "" } } }

      it "レコードが作成されないこと" do
        expect {
          perform_post(invalid_params)
        }.not_to change(Post, :count)
      end

      it "エラーメッセージが表示されること" do
        perform_post(invalid_params)
        expect(response.body).to include("内容を入力してください")
      end

      it "422 Unprocessable Entity が返り、フォームが再描画されること" do
        perform_post(invalid_params)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('turbo-stream action="replace" target="post-form"')
      end

      it "入力済みの内容を保持したままであること" do
        long_content = "a" * 1001
        perform_post(post: { content: long_content })
        expect(response.body).to include(long_content)
      end
    end

    context "Turbo Stream 形式でのリクエストの場合" do
      let(:invalid_params) { { post: { content: "" } } }

      it "422ステータスと正しい Turbo Stream レスポンスを返すこと" do
        perform_post(invalid_params)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
        expect(response.body).to include('turbo-stream action="replace" target="post-form"')
      end
    end

    context "短時間に連続して投稿した場合" do
      it "エラーになること" do
        perform_post(post: { content: "1回目" })
        expect {
          perform_post(post: { content: "2回目" })
        }.not_to change(Post, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /posts/:id" do
    let(:user) { create(:user) }
    let!(:post) { create(:post, user: user) }
    let(:other_user) { create(:user) }
    let!(:other_user_post) { create(:post, user: other_user) }

    before { sign_in user }

    it "投稿が削除され、Post レコードが1減ること" do
      expect {
        delete post_path(post)
      }.to change(Post, :count).by(-1)
    end

    it "削除されたあと、303 See Other でリダイレクトすること" do
      delete post_path(post)
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path)
    end

    context "他人の投稿を削除しようとした場合" do
      it "ActiveRecord::RecordNotFound が発生すること（404）" do
        delete post_path(other_user_post)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "未ログインの場合" do
      before { sign_out user }

      it "ログイン画面にリダイレクトされること" do
        delete post_path(post)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "投稿が削除されないこと" do
        expect {
          delete post_path(post)
        }.not_to change(Post, :count)
      end
    end
  end

  describe "Redirect after deletion" do
    let(:user) { create(:user) }
    let!(:post_record) { create(:post, user: user) }

    before { sign_in user }

    context "when maintaining filter parameters" do
      it_behaves_like "redirect_manageable_behavior", method: :delete do
        let(:action_path) { post_path(post_record) }
        let(:referer_url) { profile_url(city_id: 5) }
        let(:expected_path) { profile_path(city_id: 5) }
      end
    end
  end
end
