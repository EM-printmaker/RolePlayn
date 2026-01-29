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
      expect { post shuffles_path }.to(change { session[:viewing_city_id] })
      expect(session[:viewing_city_id]).to be_present
    end

    it "セッションに保存されるキャラクターが更新されること" do
      expect { post shuffles_path }.to(change { session[:active_character_id] })
      expect(session[:active_character_id]).to be_present
    end

    it "更新した街にリダイレクトされること"
  end
end
