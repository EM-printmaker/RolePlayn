require 'rails_helper'

RSpec.describe "Tops", type: :request do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "GET root_path" do
    let(:character) { create(:character, city: city) }
    let!(:expression) { create(:expression, :with_image, character: character) }
    let!(:post) do
      create(:post,
        city: city, character: character, expression: expression,
        created_at: 1.day.ago
      )
    end
    let!(:new_post) do
      create(:post,
        city: city, character: character, expression: expression,
        created_at: Time.current
      )
    end

    before do
      create(:city, :observer, target_world_id: world.id)
      get root_path
    end

    it_behaves_like "character_session_manageable", :root_path

    it "正常なレスポンスが返ること" do
      expect(response).to have_http_status(:success)
    end

    it "街・キャラ・投稿・画像が含まれていること" do
      expect(response.body).to include(city.name)
      expect(response.body).to include(character.name)
      expect(response.body).to include(post.content)
      expect(response.body).to include(expression.image.filename.to_s)
    end

    it "新規投稿用のオブジェクトが準備されていること" do
      expect(response.body).to include('form')
      expect(response.body).to include('post[content]')
    end

    it "表示される投稿が最新順（created_at DESC）であること" do
      expect(response.body.index(new_post.content)).to be < response.body.index(post.content)
    end

    context "投稿が一件もない場合" do
      before do
        Post.delete_all
        get root_path
      end

      it "エラーにならず正常にページが表示されること" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET top/load_more" do
    before do
      create_list(:post, 11, :with_full_data, parent_city: city)
      create(:city, :observer, target_world_id: world.id)
      get root_path
    end

    it_behaves_like "posts_load_more_behavior", :load_more_top_path
  end
end
