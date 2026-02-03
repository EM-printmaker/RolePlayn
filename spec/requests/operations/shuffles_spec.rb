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
  end
end
