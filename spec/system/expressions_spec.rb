require 'rails_helper'

RSpec.describe "Expressions", type: :system do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }
  let(:character) { create(:character, city: city) }
  let!(:expression) { create(:expression, :with_image, character: character, emotion_type: "joy", level: 1) }

  before do
    driven_by(:cuprite)
    visit city_path(city)
    click_button "表情を変更"
  end

  it "表情変更モーダルが開くこと" do
    expect(page).to have_css("dialog#expression-modal[open]")
  end

  it "感情を追加すると該当する表情をプレビューできること" do
    find("form[action*='view_type=joy']").click_button
    expect(page).to have_css("#expression_link_#{expression.id}")
  end

  it "表情一覧を表示できること" do
    click_button "すべての表情"
    expect(page).to have_css("#expression_link_#{expression.id}")
  end

  context "ログインユーザーの場合" do
    let(:user) { create(:user) }
    let!(:other_character) { create(:character, :with_expressions, city: city) }

    before do
      create(:character_assignment,
        user: user,
        city: city,
        character: character,
        expression: expression
      )
      sign_in user
      visit city_path(city)
      click_button "表情を変更"
    end

    it "表情をお気に入りに追加できること" do
      click_button "すべての表情"
      expect {
        find("#fav_exp_grid_#{expression.id}").click_button
      }.to change(ExpressionFavorite, :count).by(1)
    end

    it "表情お気に入り一覧が表示されること" do
      create(:expression_favorite, user: user, expression: expression)
      click_button "お気に入り"
      expect(page).to have_css("#expression_link_#{expression.id}")
    end

    it "キャラクター一覧からキャラクターの選択ができること" do
      find("form[action='#{character_selections_path}'] button", text: other_character.name).click
      expect(page).to have_css(".character-selector-wrapper .text-primary", text: other_character.name)
    end
  end
end
