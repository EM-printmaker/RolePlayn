require 'rails_helper'

RSpec.describe "Favorites", type: :system do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }
  let(:character) { create(:character, city: city) }
  let(:expression) { create(:expression, :with_image, character: character) }
  let(:user) { create(:user) }
  let!(:post) { create(:post, city: city, character: character, expression: expression) }

  context "ログインユーザーの場合" do
    before do
      sign_in user
      visit root_path
    end

    it "お気に入りボタンが表示されること" do
      expect(page).to have_css("##{dom_id(post, :favorite)} button")
    end

    it "投稿をお気に入りに追加できること" do
      expect {
        within "##{dom_id(post, :favorite)}" do
          click_button
        end
      }.to change(PostFavorite, :count).by(1)
    end

    it "お気に入りを解除できること" do
      create(:post_favorite, user: user, post: post)
      visit root_path

      expect {
        within "##{dom_id(post, :favorite)}" do
          click_button
        end
      }.to change(PostFavorite, :count).by(-1)
    end
  end

  context "ゲストユーザーの場合" do
    it "お気に入りボタンが表示されないこと" do
      visit root_path
      expect(page).not_to have_css("##{dom_id(post, :favorite)} button")
    end
  end
end
