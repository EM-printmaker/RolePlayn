require 'rails_helper'

RSpec.describe "Operations::Expressions", type: :request do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "POST /expressions" do
    let(:character) { create(:character, city: city) }
    let!(:joy_expression) do
      create(:expression,
        :with_image,
        character: character,
        emotion_type: "joy",
        level: 1
      )
    end
    let!(:fun_expression) do
      create(:expression,
        :with_image,
        character: character,
        emotion_type: "fun",
        level: 1
      )
    end

    def current_guest_assignment
      city_id = session[:viewing_city_id].to_s
      session.dig(:guest_assignments, city_id)
    end

    before do
      allow(Expression).to receive(:pick_random).and_return(fun_expression)
      get root_path
    end

    it "セッションに保存される表情が更新され、元のページにリダイレクトされること" do
      post expressions_path,
        params: { expression_id: joy_expression.id },
        headers: { "HTTP_REFERER" => root_path }

      expect(current_guest_assignment["expression_id"]).to eq joy_expression.id

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end

    it "フォームの画像URLが選択した表情で更新されること" do
      post expressions_path,
        params: { expression_id: joy_expression.id },
        headers: { "HTTP_REFERER" => root_path }
      follow_redirect!
      expect(response.body).to include(joy_expression.image.filename.to_s)
    end

    context "ログインユーザーの場合" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "データベース(CharacterAssignment)の表情IDが更新されること" do
        get root_path
        post expressions_path,
          params: { expression_id: joy_expression.id },
          headers: { "HTTP_REFERER" => root_path }
        assignment = CharacterAssignment.find_by(user: user, city: city)
        expect(assignment.expression_id).to eq joy_expression.id
      end
    end

    context "存在しない表情IDが送られた場合" do
      it "セッションは更新されないこと" do
        initial_id = current_guest_assignment["expression_id"]
        post expressions_path, params: { expression_id: 999_999 }
        expect(current_guest_assignment["expression_id"]).to eq initial_id
      end

      it "city_id が欠落している場合、エラーにならず元のページ等へ戻ること" do
        post expressions_path, params: { expression_id: joy_expression.id }
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
