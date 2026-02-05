require 'rails_helper'

RSpec.describe "ApplicationController", type: :request do
  let(:target_path) { root_path }

  describe "#set_all_worlds" do
    let(:world) { create(:world) }

    before { create(:city, world: world) }

    it "@worlds に必要な属性が含まれた World がセットされていること" do
      get target_path
      worlds = controller.instance_variable_get(:@worlds)

      expect(worlds.first.id).to eq world.id
      expect(worlds.first.name).to eq world.name
      expect(worlds.first.slug).to eq world.slug
    end

    it "menu_cities がプリロードされていること" do
      get target_path
      worlds = controller.instance_variable_get(:@worlds)

      expect(worlds.first.association(:menu_cities)).to be_loaded
    end

    it "select で指定していない属性にアクセスするとエラーになること" do
      get target_path
      worlds = controller.instance_variable_get(:@worlds)

      if World.column_names.include?("description")
        expect { worlds.first.description }.to raise_error(ActiveModel::MissingAttributeError)
      end
    end
  end

  describe "#reject_suspended_user" do
    context "ログイン中のユーザーが凍結された場合" do
      let(:user) { create(:user) }

      before do
        sign_in user
        user.update!(suspended_at: Time.current)
      end

      it "強制的にログアウトされ、ログインページにリダイレクトされること" do
        get target_path

        expect(response).to redirect_to(user_session_path)
        follow_redirect!
        expect(controller.user_signed_in?).to be false
      end
    end
  end
end
