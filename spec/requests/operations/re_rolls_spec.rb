require 'rails_helper'

RSpec.describe "Operations::ReRolls", type: :request do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }

  describe "POST /re_rolls" do
    let!(:character) { create(:character, :with_expressions, city: city) }

    before do
      create(:character, :with_expressions, city: city)
      get root_path
    end

    it "セッションに保存されるキャラクターの表情が更新されること" do
      expect { post re_rolls_path }.to(change { session[:active_expression_id] })

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path(format: :html))
      expect(session[:active_expression_id]).to be_present
    end
  end
end
