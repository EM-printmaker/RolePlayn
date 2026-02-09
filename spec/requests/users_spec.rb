require 'rails_helper'

RSpec.describe "Users", type: :request do
require 'rails_helper'
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "GET profile_path" do
    let(:user) { create(:user) }
    let(:another_city) { create(:city) }
    let(:other_user) { create(:user) }
    let!(:post_record) { create(:post, user: user, city: city) }
    let!(:another_city_post) { create(:post, user: user, city: another_city) }
    let!(:other_user_post) { create(:post, user: other_user, city: city) }

    before do
      sign_in user
    end

    it_behaves_like "favorite_lookup_behavior", -> { profile_path }

    it "city_idのパラメータがない場合は全ての街の投稿を返すこと" do
      get profile_path
      expect(response.body).to include(post_record.content, another_city_post.content)
    end

    it "city_idのパラメータがある場合はその街の投稿のみに絞り込まれること" do
      get profile_path(city_id: city.id)
      expect(response.body).to include(post_record.content)
      expect(response.body).not_to include(another_city_post.content)
    end

    it "自分の投稿のみが表示されること" do
      get profile_path
      expect(response.body).to include(post_record.content)
      expect(response.body).not_to include(other_user_post.content)
    end
  end

  describe "GET favorited_posts_profile_path" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:favorited_post) { create(:post, user: other_user, city: city) }
    let!(:my_post) { create(:post, user: user, city: city) }
    let!(:unrelated_post) { create(:post, user: other_user, city: city) }

    before do
      sign_in user
      create(:post_favorite, user: user, post: favorited_post)
    end

    it "お気に入り登録した投稿のみが表示されること" do
      get favorited_posts_profile_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(favorited_post.content)
      expect(response.body).not_to include(my_post.content)
      expect(response.body).not_to include(unrelated_post.content)
    end

    context "city_idによる絞り込みがある場合" do
      let(:other_city_post) { create(:post) }

      before do
        create(:post_favorite, user: user, post: other_city_post)
      end

      it "指定した街のお気に入り投稿のみが表示されること" do
        get favorited_posts_profile_path(city_id: city.id)

        expect(response.body).to include(favorited_post.content)
        expect(response.body).not_to include(my_post.content)
        expect(response.body).not_to include(other_city_post.content)
      end
    end
  end

  describe "GET #load_more" do
    let(:user) { create(:user) }

    before do
      create_list(:post, 11, user: user, city: city)
      sign_in user
      get profile_path
    end

    it_behaves_like "posts_load_more_behavior", -> { load_more_profile_path(city_id: city.id) }
  end
end
