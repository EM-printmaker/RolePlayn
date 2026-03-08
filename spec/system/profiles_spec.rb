require 'rails_helper'

RSpec.describe "Profiles", type: :system do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }
  let(:character) { create(:character, city: city) }
  let(:expression) { create(:expression, :with_image, character: character) }
  let(:user) { create(:user) }
  let!(:post) { create(:post, city: city, character: character, expression: expression, user: user) }

  before do
    sign_in user
    visit profile_path
  end

  it "自分の投稿一覧が表示されること" do
    expect(page).to have_css("##{dom_id(post)}")
  end

  it "お気に入り一覧が表示されること" do
    create(:post_favorite, user: user, post: post)
    visit favorited_posts_profile_path
    expect(page).to have_css("##{dom_id(post)}")
  end

  it "街で絞り込むと該当する投稿のみ表示されること" do
    other_city = create(:city, world: world)
    other_character = create(:character, city: other_city)
    other_expression = create(:expression, :with_image, character: other_character)
    other_post = create(:post, city: other_city, character: other_character, expression: other_expression, user: user)

    visit profile_tab_filter_path("posts", city.id)

    expect(page).to have_css("##{dom_id(post)}")
    expect(page).not_to have_css("##{dom_id(other_post)}")
  end

  it "絞り込んだ状態で投稿すると絞り込みが継続されること" do
    visit profile_tab_filter_path("posts", city.id)
    fill_in "いまのあなたは？", with: "絞り込み状態の投稿"
    click_button "つぶやく"
    expect(page).to have_text("絞り込み状態の投稿")
    expect(page).to have_current_path(profile_path(city_id: city.id), ignore_query: false)
  end
end
