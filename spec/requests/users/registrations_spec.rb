require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "PUT /users (user_registration_path)" do
    context "login_id が未設定の場合 (初回セットアップ)" do
      let(:user) { create(:user, login_id: nil) }

      before do
        allow(User).to receive(:find_by).and_call_original
        allow(User).to receive(:find_by).with(id: user.id).and_return(user)
        allow(user).to receive(:just_set_login_id?).and_return(true)
      end

      it "現在のパスワードなしで更新でき、root_path へリダイレクトすること" do
        put user_registration_path, params: {
          user: { login_id: "new_unique_id", email: "new@example.com" }
        }

        expect(user.reload.login_id).to eq "new_unique_id"
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq I18n.t("devise.registrations.initial_setup_completed")
      end
    end

    context "login_id が設定済みの場合 (通常更新)" do
      let(:password) { "password123" }
      let(:user) { create(:user, login_id: "existing_id", password: password, password_confirmation: password) }

      it "現在のパスワードがないと更新に失敗すること" do
        put user_registration_path, params: {
          user: { email: "fail@example.com" }
        }

        expect(response.status).to eq(422) # Unprocessable Entity
        expect(user.reload.email).not_to eq "fail@example.com"
      end

      it "現在のパスワードがあれば確認メール送信待ち状態になり、編集画面へ戻ること" do
        new_email = "success@example.com"
        put user_registration_path, params: {
          user: { email: new_email, current_password: password }
        }
        expect(user.reload.email).not_to eq new_email
        expect(user.unconfirmed_email).to eq new_email
        expect(response).to redirect_to(edit_user_registration_path)
        expect(flash[:notice]).to include I18n.t("devise.registrations.update_needs_confirmation")
      end
    end
  end

  describe "GET /settings/password (edit_password_settings_path)" do
    it "正常にレスポンスを返すこと" do
      get edit_password_settings_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include "password"
    end
  end

  describe "PATCH /settings/password (update_password_settings_path)" do
    let(:new_password) { "new_password_1234" }

    context "正しい現在のパスワードを入力した場合" do
      it "パスワードが更新され、ログイン状態が維持されること" do
        patch update_password_settings_path, params: {
          user: {
            current_password: user.password,
            password: new_password,
            password_confirmation: new_password
          }
        }

        expect(user.reload.valid_password?(new_password)).to be true
        expect(response).to redirect_to(edit_user_registration_path)
        expect(flash[:notice]).to eq I18n.t("devise.registrations.password_updated")
      end
    end

    context "現在のパスワードが間違っている場合" do
      it "更新に失敗し、422エラーを返すこと" do
        patch update_password_settings_path, params: {
          user: {
            current_password: "wrong_password",
            password: new_password,
            password_confirmation: new_password
          }
        }

        expect(response.status).to eq(422)
        expect(user.reload.valid_password?(new_password)).to be false
      end
    end
  end
end
