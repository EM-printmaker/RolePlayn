require 'rails_helper'

RSpec.describe "Favorites::Posts", type: :request do
  describe "POST favorites/posts" do
    let(:user) { create(:user) }
    let!(:post_record) { create(:post) }

    before do
      sign_in user
    end

    it "お気に入りを作成し、要素を更新するTurbo Streamを返すこと" do
      target_id = "favorite_post_#{post_record.id}"
      expect {
        post post_favorite_path(post_id: post_record.id), as: :turbo_stream
      }.to change(PostFavorite, :count).by(1)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(%(target="#{target_id}"))
      expect(response.body).to include('turbo-stream action="replace"')
    end
  end

  describe "DELETE favorites/posts" do
    let(:user) { create(:user) }
    let(:post_record) { create(:post) }

    before do
      sign_in user
      create(:post_favorite, user: user, post: post_record)
    end

    it "お気に入りを削除し、要素を更新するTurbo Streamを返すこと" do
      target_id = "favorite_post_#{post_record.id}"
      expect {
        delete post_favorite_path(post_id: post_record.id), as: :turbo_stream
      }.to change(PostFavorite, :count).by(-1)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(%(target="#{target_id}"))
      expect(response.body).to include('turbo-stream action="replace"')
    end
  end
end
