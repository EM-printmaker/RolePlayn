require 'rails_helper'

RSpec.describe "Inquiries", type: :request do
  describe "GET /new" do
    it "正常にレスポンスを返すこと" do
      get new_inquiry_path
      expect(response).to have_http_status(:success)
    end

    it "ログイン時にはユーザー情報がフォームの初期値にセットされていること" do
      user = create(:user, login_id: "test_user", email: "test@example.com")
      sign_in user

      get new_inquiry_path
      html = Nokogiri::HTML(response.body)

      expect(html.at('input[@name="inquiry[name]"]')['value']).to eq "test_user"
      expect(html.at('input[@name="inquiry[email]"]')['value']).to eq "test@example.com"
    end
  end

  describe "POST /confirm" do
    it "有効なパラメータの場合、正常にレスポンスを返すこと" do
      post confirm_inquiries_path, params: { inquiry: attributes_for(:inquiry) }
      expect(response).to have_http_status(:success)
    end

    context "パラメータが無効な場合" do
      it "new テンプレートを ステータス422 で再描画すること" do
        post confirm_inquiries_path, params: { inquiry: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /create" do
    it "正常に保存され、完了画面にリダイレクトすること" do
      expect {
        post inquiries_path, params: { inquiry: attributes_for(:inquiry) }
      }.to change(Inquiry, :count).by(1)

      expect(response).to redirect_to(done_inquiries_path)
    end

    context "戻るボタンが押された場合" do
      it "保存されずに new テンプレートを再描画すること" do
        expect {
          post inquiries_path, params: { inquiry: attributes_for(:inquiry), back: "戻る" }
        }.not_to change(Inquiry, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "保存に失敗した場合" do
      it "new テンプレートを再描画すること" do
        expect {
          post inquiries_path, params: { inquiry: { name: "" } }
        }.not_to change(Inquiry, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /done" do
    it "正常にレスポンスを返すこと" do
      get done_inquiries_path
      expect(response).to have_http_status(:success)
    end
  end
end
