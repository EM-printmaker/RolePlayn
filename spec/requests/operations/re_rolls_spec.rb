require 'rails_helper'

RSpec.describe "Operations::ReRolls", type: :request do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "POST /re_rolls" do
    let(:character) { create(:character, city: city) }
    let(:expression) { create(:expression, :with_image, character: character) }
    let(:new_character) { create(:character, city: city) }
    let(:new_expression) { create(:expression, :with_image,  character: new_character) }

    def current_guest_assignment
      session.dig(:guest_assignments, city.id.to_s)
    end

    before do
      allow(Expression).to receive(:pick_random).and_return(expression, new_expression)
      get root_path
    end

    it "セッションに保存されるキャラクターの表情が更新されること" do
      initial_assignment = current_guest_assignment
      initial_character_id = initial_assignment["character_id"]

        post re_rolls_path(city_id: city.id),
          headers: { "HTTP_REFERER" => world_city_path(world, city) }

        new_assignment = current_guest_assignment
        expect(new_assignment["character_id"]).not_to eq(initial_character_id)
        expect(new_assignment["character_id"]).to be_present
        expect(new_assignment["expression_id"]).to be_present
    end

    context "ログインユーザーの場合" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "データベース(CharacterAssignment)のレコードが更新されること" do
        get world_city_path(world, city)
        initial_assignment = CharacterAssignment.find_by(user: user, city: city)
        initial_character_id = initial_assignment.character_id

        post re_rolls_path(city_id: city.id)

        updated_assignment = initial_assignment.reload
        expect(updated_assignment.character_id).not_to eq(initial_character_id)
      end
    end
  end
end
