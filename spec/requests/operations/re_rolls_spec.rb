require 'rails_helper'

RSpec.describe "Operations::ReRolls", type: :request do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "POST /re_rolls" do
    let(:character) { create(:character, city: city) }
    let(:expression) { create(:expression, :with_image, character: character) }
    let(:new_character) { create(:character, city: city) }
    let(:new_expression) { create(:expression, :with_image,  character: new_character) }

    before do
      allow(Expression).to receive(:pick_random).and_return(expression, new_expression)
      get root_path
    end

    it "セッションに保存されるキャラクターの表情が更新されること" do
      previous_expression_id = session[:active_expression_id]
      post re_rolls_path
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path(format: :html))

      expect(session[:active_expression_id]).not_to eq(previous_expression_id)
      expect(session[:active_expression_id]).to be_present
    end
  end
end
