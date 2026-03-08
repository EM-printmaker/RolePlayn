require 'rails_helper'

RSpec.describe "Operations::Shuffles", type: :system do
  let(:world) { create(:world) }
  let!(:current_city) { create(:city, world: world) }
  let!(:other_city) { create(:city, world: world) }

  before do
    create(:character, :with_expressions, city: current_city)
    create(:character, :with_expressions, city: other_city)
  end

  it "シャッフルすると別の街が表示されること" do
    visit city_path(current_city)
    click_button "他の街へ移動"
    expect(page).to have_css(".city-select-button", text: other_city.name)
  end
end
