require 'rails_helper'

RSpec.describe "Observations", type: :request do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "GET /:world_slug/:city_slug/observations/:subject_id" do
    let!(:global_city) { create(:city, :observer, target_world_id: world.id) }
    let(:character) { create(:character, city: city) }
    let!(:post) do
      create(:post, :with_full_data,
        parent_city: city,
        given_character: character,
      )
    end

    before do
      get observation_path(character)
    end

    it "正常なレスポンスが返ること" do
      expect(response).to have_http_status(:success)
    end

    it "期待通りのURLが生成されること" do
      expected_path = "/#{global_city.world.slug}/#{global_city.slug}/observations/#{character.id}"
      expect(observation_path(character)).to eq expected_path
    end

    it "街(node)の名前が含まれていること" do
      expect(response.body).to include(global_city.name)
    end

    it "対象キャラクターの名前・投稿内容・画像が含まれていること" do
        expect(response.body).to include(character.name)
        expect(response.body).to include(post.content)
        expect(response.body).to include(post.expression.image.filename.to_s)
    end

    context "不正なアクセス（キャラが所属する街など、観測用ではない街から）の場合" do
      it "公式な観測用の街のURLへリダイレクトされること" do
        wrong_path = "/#{world.slug}/#{city.slug}/observations/#{character.id}"
        get wrong_path

        expect(response).to redirect_to(observation_path(character))
        expect(response).to have_http_status(:moved_permanently)
      end
    end

    context "存在しないsubject_idを指定した場合" do
      it "存在しないリソースのため、404 Not Found が返ること" do
        get "/#{global_city.world.slug}/#{global_city.slug}/observations/999999"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "対象の世界を観測する街(node)が存在しない場合" do
      let!(:all_local_city) { create(:city, :all_local, :global) }

      before do
        global_city.delete
        get observation_path(character)
      end

      it "全ての世界の投稿を表示する街(node)で正常に表示されること" do
        expected_path = "/#{all_local_city.world.slug}/#{all_local_city.slug}/observations/#{character.id}"
        expect(observation_path(character)).to eq expected_path
      end
    end

    context "対象キャラクターに投稿が1つもない場合" do
      let(:lonely_character) { create(:character, city: city) }

      it "エラーにならず、専用のメッセージが表示されること" do
        get observation_path(lonely_character)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("投稿はまだありません")
      end
    end
  end

  describe "GET /:world_slug/:city_slug/observations/:subject_id/load_more" do
    let(:character) { create(:character, city: city) }
    let(:global_city) { create(:city, :observer, target_world_id: world.id)  }

    before do
      create_list(:post, 11, :with_full_data, parent_city: city, given_character: character)
      get observation_path(character)
    end

    it_behaves_like "posts_load_more_behavior", -> { load_more_observation_path(global_city, character) }
  end
end
