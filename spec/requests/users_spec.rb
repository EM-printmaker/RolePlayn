require 'rails_helper'

RSpec.describe "Users", type: :request do
require 'rails_helper'
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "GET profile_path" do
    let(:user) { create(:user) }
    let(:another_city) { create(:city) }
    let(:other_user) { create(:user) }
    let!(:post) { create(:post, user: user, city: city) }
    let!(:another_city_post) { create(:post, user: user, city: another_city) }
    let!(:other_user_post) { create(:post, user: other_user, city: city) }

    before do
      sign_in user
    end

    it "city_idのパラメータがない場合は全ての街の投稿を返すこと" do
      get profile_path
      expect(response.body).to include(post.content, another_city_post.content)
    end

    it "city_idのパラメータがある場合はその街の投稿のみに絞り込まれること" do
      get profile_path(city_id: city.id)
      expect(response.body).to include(post.content)
      expect(response.body).not_to include(another_city_post.content)
    end

    it "自分の投稿のみが表示されること" do
      get profile_path
      expect(response.body).to include(post.content)
      expect(response.body).not_to include(other_user_post.content)
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
