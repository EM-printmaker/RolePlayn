require 'rails_helper'

RSpec.describe "Sessions", type: :system do
  let(:world) { create(:world) }
  let(:city)  { create(:city, world: world) }

  before do
    driven_by(:cuprite)
    create(:character, :with_expressions, city: city)
  end

  context "初回ログインの場合" do
    let(:user) { create(:user, login_id: nil) }

    it "プロフィール編集画面へリダイレクトされること" do
      visit new_user_session_path
      fill_in "ユーザーID または メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"
      expect(page).to have_current_path(edit_user_registration_path)
    end
  end

  context "ゲストの割り当てがある場合" do
    let(:user) { create(:user, login_id: "test_user") }

    it "ログイン後にゲストの割り当てがDBに移行されること" do
      visit root_path

      guest_image_src = find(".current-character__image")["src"]

      visit new_user_session_path
      fill_in "ユーザーID または メールアドレス", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"
      filename = File.basename(URI.parse(guest_image_src).path)
      expect(page).to have_css(".current-character__image[src*='#{filename}']")
      expect(CharacterAssignment.exists?(user: user, city: city)).to be true
    end
  end
end
