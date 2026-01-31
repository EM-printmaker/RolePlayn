require "rails_helper"

RSpec.describe "Custom Direct Routes", type: :routing do
  let(:world) { create(:world) }
  let(:city) { create(:city, world: world) }
  let(:character) { create(:character, city: city) }

  describe "direct :city" do
    it "cityオブジェクトから正しいパスを生成すること" do
      expect(city_path(city)).to eq "/#{world.slug}/#{city.slug}"
    end
  end

  describe "direct :observation" do
    let(:global_city) { create(:city, :observer, target_world_id: world.id, slug: "obs-city") }

    it "グローバルな世界と街経由のパスを生成すること" do
      expected_path = "/#{global_city.world.slug}/#{global_city.slug}/observations/#{character.id}"
      expect(observation_path(character)).to eq expected_path
    end
  end
end
