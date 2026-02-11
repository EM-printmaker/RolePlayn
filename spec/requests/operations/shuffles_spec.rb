require 'rails_helper'

RSpec.describe "Operations::Shuffles", type: :request do
  describe "POST /shuffles" do
    let(:cities) { create_list(:city, 2) }

    before do
      cities.each do |city|
        create(:character, :with_expressions, city: city)
      end
      get root_path
    end

    it "セッションに保存される街が更新されること" do
      initial_city_id = session[:viewing_city_id]
      post shuffles_path
      expect(session[:viewing_city_id]).not_to eq(initial_city_id)
      expect(session[:viewing_city_id]).to be_present
    end

    it "セッションに保存されるキャラクターが更新されること" do
      post shuffles_path
      new_city_id = session[:viewing_city_id]
      assignment = session.dig(:guest_assignments, new_city_id.to_s)
      expect(assignment).to be_present
      expect(assignment["character_id"]).to be_present
    end

    context "ログインユーザーの場合" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "移動先の街の CharacterAssignment レコードが作成されること" do
        post shuffles_path
        new_city_id = session[:viewing_city_id]

        assignment = CharacterAssignment.find_by(user: user, city_id: new_city_id)
        expect(assignment).to be_present
      end
    end

    context "プロフィール画面からシャッフルした場合" do
      let!(:new_city) { create(:city) }

      it "新しく選ばれた街のパラメータ付きでプロフィールへ戻ること" do
        allow(City).to receive(:pick_random).and_return(new_city)

        post shuffles_path, headers: { "HTTP_REFERER" => profile_url }

        expect(response).to redirect_to("/profile?city_id=#{new_city.id}")
        expect(flash[:scroll_to_top]).to be true
      end
    end

    context "トップ画面からシャッフルした場合" do
      let!(:new_city) { create(:city) }

      it "パラメータなしでトップへ戻ること" do
        allow(City).to receive(:pick_random).and_return(new_city)

        post shuffles_path, headers: { "HTTP_REFERER" => root_url }

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "Redirect maintenance" do
    let(:user) { create(:user) }
    let(:city) { create(:city) }

    before do
      sign_in user
      allow(City).to receive(:pick_random).and_return(city)
    end

    context "when executed from Profile page" do
      it_behaves_like "redirect_manageable_behavior" do
        let(:action_path) { shuffles_path }
        let(:referer_url) { profile_url }
        let(:expected_path) { profile_path(city_id: city.id) }
      end
    end

    context "when executed from City Show page" do
      let(:old_city) { create(:city) }

      it_behaves_like "redirect_manageable_behavior" do
        let(:action_path) { shuffles_path }
        let(:referer_url) { world_city_url(world_slug: old_city.world.slug, slug: old_city.slug) }
        let(:expected_path) { world_city_path(world_slug: city.world.slug, slug: city.slug) }
      end
    end
  end
end
