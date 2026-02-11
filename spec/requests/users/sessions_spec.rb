require 'rails_helper'

RSpec.describe "Users::Sessions", type: :request do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "GET /users/sign_in" do
    it "ログイン画面が正しく表示されること" do
      get new_user_session_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ユーザーID または メールアドレス")
    end
  end

  describe "POST /users/sign_in" do
    let(:user) { create(:user, email: "test@example.com", login_id: "test_user", password: "password123") }

    before do
      create(:character, :with_expressions, city: city)
      create(:city, :observer, target_world_id: world.id)
    end

    it "メールアドレスでログインできること" do
      post user_session_path, params: { user: { login: user.email, password: user.password } }
      expect(response).to have_http_status(:see_other)
      follow_redirect!
      expect(response.body).to include("ログインしました")
    end

    it "login_id でログインできること" do
      post user_session_path, params: { user: { login: user.login_id, password: user.password } }
      expect(response).to have_http_status(:see_other)
    end

    it "大文字混じりの入力でもログインできること" do
      post user_session_path, params: { user: { login: "TEST_USER", password: user.password } }
      expect(response).to have_http_status(:see_other)
    end

    context "初回ログイン時のリダイレクト挙動" do
      it "初回ログインかつID未設定なら、プロフィール編集画面へ飛ばすこと" do
        new_user = create(:user, login_id: nil) # sign_in_count 0
        post user_session_path, params: { user: { login: new_user.email, password: new_user.password } }

        expect(response).to redirect_to(edit_user_registration_path)

        follow_redirect!
        expect(response.body).to include("ユーザーIDを設定しましょう")
      end

      it "2回目以降のログインなら、通常のトップページへ飛ばすこと" do
        user.update(sign_in_count: 5)
        post user_session_path, params: { user: { login: user.email, password: user.password } }

        expect(response).to redirect_to(root_path)
      end
    end

    context "認証に失敗する場合" do
      it "無効なパスワードではログインできないこと" do
        post user_session_path, params: { user: { login: user.email, password: "wrong_password" } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("ユーザーID・メールアドレスまたはパスワードが違います")
      end
    end

    context "アカウントが凍結(suspended)されている場合" do
      let(:suspended_user) { create(:user, suspended_at: Time.current) }

      it "正しいパスワードを入力してもログインできず、凍結メッセージが表示されること" do
        post user_session_path, params: { user: { login: suspended_user.email, password: suspended_user.password } }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)

        follow_redirect!

        expect(response.body).to include("ログイン")
        expect(response.body).to include("凍結")
      end
    end

    context "アカウントがロック(locked)されている場合" do
      let(:locked_user) { create(:user) }

      before do
        locked_user.lock_access!
      end

      it "正しいパスワードを入力してもログインできず、ロックメッセージが表示されること" do
        post user_session_path, params: { user: { login: locked_user.email, password: locked_user.password } }

        expect(controller).not_to be_user_signed_in

        expect(response.body).to include("ロック")
      end
    end
  end

  describe "DELETE /users/sign_out" do
    let(:user) { create(:user) }

    before do
      create(:character, :with_expressions, city: city)
      create(:city, :observer, target_world_id: world.id)
    end

    it "ログアウトしてセッションが破棄され、トップページへ飛ぶこと" do
      sign_in user
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
      expect(controller).not_to be_user_signed_in
      follow_redirect!
      expect(response.body).to include("ログアウトしました")
    end
  end

  describe "#after_sign_in_path_for" do
    let(:user) { create(:user) }

    before do
      character = create(:character, city: city)
      create(:expression, :with_image, character: character)
    end

    it "ログイン後にデータがDBに移行され、セッションから削除されること" do
      get city_path(city)
      expect(session[:guest_assignments]).to be_present
      post user_session_path,
        params: { user: { login: user.email, password: user.password } }

      expect(CharacterAssignment.exists?(user: user, city: city)).to be true
      expect(session[:guest_assignments]).to be_nil
    end
  end
end
