require 'rails_helper'

RSpec.describe "Expressions", type: :request do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "POST expressions/preview" do
    let(:character) { create(:character, city: city) }
    let(:joy_expression) do
    create(:expression,
      :with_image,
      character: character,
      emotion_type: "joy",
      level: 1
    )
    end
    let(:valid_params) do
      { view_type: "joy", view_level: "1" }
    end

    it "正常なレスポンスが返ること" do
      joy_expression
      post preview_expressions_path, params: valid_params, as: :turbo_stream
      expect(response).to have_http_status(:success)
    end

    it "Turbo Stream形式でモーダルの内容が返ってくること" do
      joy_expression
      post preview_expressions_path, params: valid_params, as: :turbo_stream
      expect(response.body).to include('turbo-stream action="update" target="expression-modal-content"')
    end

    context "表情データが見つからない場合" do
      it "『画像が生成されていません』というメッセージを表示すること" do
        post preview_expressions_path, params: { view_type: "sad", view_level: "2" }, as: :turbo_stream
        expect(response.body).to include("画像が生成されていません")
      end
    end
  end

  describe "GET expressions/favorites" do
    let(:user) { create(:user) }
    let(:character) { create(:character, city: city) }
    let(:favorite_expression) { create(:expression, :with_image, :joy, character: character) }

    before do
      sign_in user
      create(:character_assignment, user: user, character: character, city: city)
      create(:expression_favorite, user: user, expression: favorite_expression)
      allow(City).to receive_messages(find_by: city, find: city)
      allow(Character).to receive(:find_by).and_return(character)
    end

    context "Turbo Frame リクエストの場合" do
      it "お気に入り一覧のパーシャルが返ってくること" do
        get favorites_expressions_path, headers: { "Turbo-Frame" => "favorites-pane" }

        expect(response).to have_http_status(:success)
        expect(response.body).to include(favorite_expression.id.to_s)
        expect(response.body).not_to include("<html>")
      end
    end
  end
end
