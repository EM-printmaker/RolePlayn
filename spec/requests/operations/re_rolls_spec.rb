require 'rails_helper'

RSpec.describe "Operations::ReRolls", type: :request do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "POST /re_rolls" do
    let(:character) { create(:character, city: city) }
    let!(:expression) { create(:expression, :with_image, character: character) }
    let(:new_character) { create(:character, city: city) }
    let!(:new_expression) { create(:expression, :with_image,  character: new_character) }
    let(:other_city) { create(:city, world: world) }
    let(:other_character) { create(:character, city: other_city) }
    let!(:other_expression) { create(:expression, :with_image, character: other_character) }


    def current_guest_assignment
      city_id = session[:viewing_city_id].to_s
      session.dig(:guest_assignments, city_id)
    end

    it "セッションに保存されるキャラクターの表情が更新されること" do
      get city_path(city)
      initial_assignment = current_guest_assignment
      initial_character_id = initial_assignment["character_id"]

        post re_rolls_path,
          headers: { "HTTP_REFERER" => city_path(city) }

        new_assignment = current_guest_assignment
        expect(new_assignment["character_id"]).not_to eq(initial_character_id)
        expect(new_assignment["character_id"]).to be_present
        expect(new_assignment["expression_id"]).to be_present
    end

    it "同じ街のキャラクターに更新されること" do
      get city_path(city)

      post re_rolls_path,
        headers: { "HTTP_REFERER" => city_path(city) }

      new_assignment = current_guest_assignment
      new_character_id = new_assignment["character_id"]

      assigned_character = Character.find(new_character_id)

      expect(assigned_character.city_id).to eq(city.id)
      expect(assigned_character.city_id).not_to eq(other_city.id)
    end

    context "ログインユーザーの場合" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "データベース(CharacterAssignment)のレコードが更新されること" do
        get city_path(city)
        initial_assignment = CharacterAssignment.find_by(user: user, city: city)
        initial_character_id = initial_assignment.character_id

        post re_rolls_path

        updated_assignment = initial_assignment.reload
        expect(updated_assignment.character_id).not_to eq(initial_character_id)
      end

      it "同じ街のキャラクターに更新されること" do
        get city_path(city)
        initial_assignment = CharacterAssignment.find_by(user: user, city: city)
        post re_rolls_path

        updated_assignment = initial_assignment.reload
        expect(updated_assignment.city_id).to eq(city.id)
        expect(updated_assignment.city_id).not_to eq(other_city.id)
      end
    end
  end
end
