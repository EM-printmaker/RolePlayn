require 'rails_helper'

RSpec.describe "Favorites::Expressions", type: :request do
    let(:world) { create(:world) }
    let(:city) { create(:city, world: world) }

  describe "POST favorites/expressions" do
    let(:user) { create(:user) }
    let(:character) { create(:character, city: city) }
    let(:expression) { create(:expression, :with_image, character: character) }

    before do
      sign_in user
    end

    it "お気に入りを作成し、3つの要素を更新するTurbo Streamを返すこと" do
      expect {
        post expression_favorite_path(expression_id: expression.id), as: :turbo_stream
      }.to change(ExpressionFavorite, :count).by(1)

      expect(response).to have_http_status(:success)
      %w[grid preview fav].each do |prefix|
        expect(response.body).to include(%(target="fav_exp_#{prefix}_#{expression.id}"))
      end
    end
  end

  describe "DELETE favorites/expressions" do
    let(:user) { create(:user) }
    let(:character) { create(:character, city: city) }
    let(:expression) { create(:expression, :with_image, character: character) }

    before do
      sign_in user
      create(:expression_favorite, user: user, expression: expression)
    end

        it "お気に入りを削除し、3つの要素を更新するTurbo Streamを返すこと" do
      expect {
        delete expression_favorite_path(expression_id: expression.id), as: :turbo_stream
      }.to change(ExpressionFavorite, :count).by(-1)

      expect(response).to have_http_status(:success)
      %w[grid preview fav].each do |prefix|
        expect(response.body).to include(%(target="fav_exp_#{prefix}_#{expression.id}"))
      end
    end
  end
end
