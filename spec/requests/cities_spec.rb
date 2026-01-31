require 'rails_helper'

RSpec.describe "Cities", type: :request do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "GET /cities" do
    it "正常なレスポンスが返ること" do
      create(:city, :all_local)
      get cities_index_path
      expect(response).to have_http_status(:found)
    end

    it "全都市の投稿を表示する都市へリダイレクトされること" do
      observer_city = create(:city, :all_local)
      get cities_index_path
      expect(response).to redirect_to(world_city_path(observer_city.world, observer_city))
    end

    context "表示可能な都市が1つもない場合" do
      before { City.delete_all }

      it "エラーページへリダイレクトされること" do
        skip "未実装"
        get cities_index_path
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /:world_slug/:slug" do
    let(:character) { create(:character, city: city) }
    let!(:expression) { create(:expression, :with_image, character: character) }
    let!(:post) do
      create(:post,
        city: city, character: character, expression: expression,
      )
    end

    before do
      create(:city, :observer, target_world_id: world.id)
      get world_city_path(world, city)
    end

    it_behaves_like "character_session_manageable", -> { city_path(city) }

    it "正常なレスポンスが返ること" do
      expect(response).to have_http_status(:success)
    end

    it "街・キャラクター・投稿・画像の情報が含まれていること" do
      expect(response.body).to include(city.name)
      expect(response.body).to include(character.name)
      expect(response.body).to include(post.content)
      expect(response.body).to include(expression.image.filename.to_s)
    end

    it "アクセスした街がセッションに保存されること" do
      expect(session[:viewing_city_id]).to eq city.id
    end

    it "その街に所属するキャラクターがセッションにセットされること" do
      expect(session[:active_character_id]).not_to be_nil
      expect(Character.find(session[:active_character_id]).city).to eq city
    end

    context "街の所属する世界がis_global:trueの場合" do
      let(:global_city) { create(:city, :observer, target_world_id: world.id) }
      let(:other_city) { create(:city, world: world) }
      let!(:other_post) { create(:post, :with_full_data, parent_city: other_city) }

      before { get world_city_path(global_city.world, global_city) }

      it "ターゲットにしている世界所属の街すべての投稿が含まれていること" do
        expect(response.body).to include(post.content)
        expect(response.body).to include(other_post.content)
      end
    end

    context "街の所属する世界がis_global:falseの場合" do
      let!(:another_post) { create(:post, :with_full_data, parent_world: world) }

      it "他の街の投稿が含まれていないこと" do
        get world_city_path(world, city)
        expect(response.body).not_to include(another_post.content)
      end
    end

    context "存在する街だが、URLのワールドスラッグと所属が一致しない場合" do
      it "404 Not Found が返ること" do
        other_world = create(:world, slug: "wrong-world")
        get "/#{other_world.slug}/#{city.slug}"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "街に投稿が1つもない場合" do
      before { Post.delete_all }

      it "「投稿はまだありません」のメッセージが表示されること" do
        get world_city_path(world, city)
        expect(response.body).to include("投稿はまだありません")
      end
    end
  end

  describe "GET /:world_slug/:slug/load_more" do
    before do
      create_list(:post, 11, :with_full_data, parent_city: city)
      create(:city, :observer, target_world_id: world.id)
      get world_city_path(world, city)
    end

    it_behaves_like "posts_load_more_behavior", -> { load_more_city_path(city) }

    context "不整合なURLでアクセスした場合" do
      it "load_moreでも404を返すこと" do
        other_world = create(:world, slug: "wrong-world")
        get "/#{other_world.slug}/#{city.slug}/load_more", as: :turbo_stream
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
