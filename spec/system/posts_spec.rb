require 'rails_helper'

RSpec.describe "Posts", type: :system do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }
  let(:character) { create(:character, city: city) }
  let(:expression) { create(:expression, :with_image, character: character) }
  let!(:post) { create(:post, city: city, character: character, expression: expression) }

  it "投稿一覧が表示されること" do
    visit root_path
    expect(page).to have_css("##{dom_id(post)}")
  end

  it "投稿を作成できること" do
    visit root_path
    fill_in "いまのあなたは？", with: "テスト投稿"
    click_button "つぶやく"
    expect(page).to have_text("テスト投稿")
  end

  context "ログインユーザーの場合" do
    let(:user) { create(:user) }
    let!(:my_post) { create(:post, city: city, character: character, expression: expression, user: user) }

    before { sign_in user }

    it "投稿を削除できること" do
      visit root_path
      expect {
        within "##{dom_id(my_post)}" do
          find("button[data-bs-toggle='dropdown']").click
          click_button "削除する"
        end
      }.to change(Post, :count).by(-1)
    end
  end
end
