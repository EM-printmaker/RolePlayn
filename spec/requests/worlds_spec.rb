require 'rails_helper'

RSpec.describe "Worlds", type: :request do
  let(:world) { create(:world) }

  describe "GET /worlds" do
    let!(:global_observer) { create(:city, :all_local, :global) }

    it "全世界を観測する街(node00)へリダイレクトされること" do
      get worlds_index_path
      expect(response).to redirect_to(city_path(global_observer))
      expect(response).to have_http_status(:found) # 302
    end
  end

  describe "GET /:slug" do
    let!(:world_observer) { create(:city, :observer, world: world, target_world_id: world.id) }

    it "ワールドを観測する街(node)へリダイレクトされること" do
        get world_path(world)
        expect(response).to redirect_to(city_path(world_observer))
    end

    context "ワールドを観測する街(node)がなく、Slugのワールドに所属する街が存在する場合" do
      before { world_observer.delete }

      let!(:first_city) { create(:city, world: world) }
      let!(:second_city) { create(:city, world: world) }

      it "その世界内の最初の街へリダイレクトされること" do
        get world_path(world)
        expect(response).to redirect_to(city_path(first_city))
      end
    end

    context "存在しないWorldスラッグの場合" do
      it "404 Not Found が返ること" do
        get "/non-existent-world"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "世界に属する街が存在しない場合" do
      before { world_observer.delete }

      it "404 Not Foundが返ること" do
        get world_path(world)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
