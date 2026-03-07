require 'rails_helper'

RSpec.describe "Operations::Expressions", type: :system do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }
  let(:character) { create(:character, city: city) }
  let!(:current_expression) { create(:expression, :with_image, character: character, emotion_type: "joy") }
  let!(:other_expression) { create(:expression, :with_image, character: character, emotion_type: "fun") }

  before do
    driven_by(:cuprite)
  end

  it "表情を選択すると現在の表情が更新されること" do
    visit city_path(city)
    click_button "表情を変更"
    click_button "すべての表情"
    click_button "", id: "expression_link_#{other_expression.id}"
    expect(page).to have_css("#current_expression img[src*='#{other_expression.image.filename}']")
  end

  context "ログインユーザーの場合" do
    let(:user) { create(:user) }
    let!(:assignment) do
      create(:character_assignment,
        user: user,
        city: city,
        character: character,
        expression: current_expression
      )
    end

    before { sign_in user }

    it "表情を選択するとDBに保存されること" do
      visit city_path(city)
      click_button "表情を変更"
      click_button "すべての表情"
      click_button "", id: "expression_link_#{other_expression.id}"
      expect(assignment.reload.expression_id).to eq(other_expression.id)
    end
  end
end
