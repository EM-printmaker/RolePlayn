require 'rails_helper'

RSpec.describe "Operations::ReRolls", type: :system do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  before do
    create_list(:character, 2, :with_expressions, city: city)
  end


  it "リロールすると同じ街の別キャラクターが表示されること" do
    visit city_path(city)
    initial_name = find(".nav-block", text: "YOUR CHARACTER").find(".fw-bold.text-truncate").text
    click_button "キャラクター更新"
    new_name = find(".nav-block", text: "YOUR CHARACTER").find(".fw-bold.text-truncate").text
    expect(new_name).not_to eq(initial_name)
  end

  context "ログインユーザーの場合" do
    let(:user) { create(:user) }

    before { sign_in user }

    it "リロールするとDBに保存されること" do
      visit city_path(city)
      expect {
        click_button "キャラクター更新"
      }.to(change { CharacterAssignment.find_by(user: user, city: city)&.character_id })
    end
  end
end
