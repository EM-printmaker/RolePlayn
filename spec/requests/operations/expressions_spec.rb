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

    before do
      allow(Expression).to receive(:pick_random).and_return(fun_expression)
      get root_path
    end

    it "セッションに保存される表情が更新され、元のページにリダイレクトされること" do
      post expressions_path,
        params: { expression_id: joy_expression.id },
        headers: { "HTTP_REFERER" => root_path }

      expect(session[:active_expression_id]).to eq joy_expression.id.to_s

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

    context "存在しない表情IDが送られた場合" do
      it "セッションは更新されないこと" do
        post expressions_path, params: { expression_id: 999_999 }
        expect(session[:active_expression_id]).to eq fun_expression.id
      end
    end
  end
end
