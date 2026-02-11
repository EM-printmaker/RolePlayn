require 'rails_helper'

RSpec.describe "Operations::CharacterSelections", type: :request do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "POST /character_selections" do
    let(:user) { create(:user) }
    let!(:character) { create(:character, :with_expressions, city: city) }

    before do
      sign_in user
      get root_path
    end

    it "DB(CharacterAssignment)の配役が更新されること" do
      post character_selections_path,
        params: { character_id: character.id },
        as: :turbo_stream

      assignment = CharacterAssignment.find_by(user: user, city: city)
      expect(assignment.character_id).to eq character.id
    end
  end
end
