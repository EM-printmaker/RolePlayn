require "rails_helper"

RSpec.describe "Routing", type: :routing do
  describe "Worlds & Cities (Dynamic Slugs)" do
    it "静的パス /worlds が一覧画面へ正しくルーティングされること" do
      expect(get: "/worlds").to route_to("worlds#index")
    end

    it "/:slugがWorld詳細画面へのルーティングであること" do
      expect(get: "/my-world-01").to route_to(
        "worlds#show",
        slug: "my-world-01"
      )
    end

    it "/:world_slug/:slugがCity詳細画面へのルーティングであること" do
      expect(get: "/my-world/my-city").to route_to(
        "cities#show",
        world_slug: "my-world",
        slug: "my-city"
      )
    end

    it "/:world_slug/:city_slug/observations/:subject_idがObservation詳細画面のルーティングであること" do
      expect(get: "/w-slug/c-slug/observations/100").to route_to(
        "observations#show",
        world_slug: "w-slug",
        city_slug: "c-slug",
        subject_id: "100"
      )
    end
  end

  describe "Constraints" do
    it "大文字を含むスラッグは許可されないこと" do
      expect(get: "/My-World").not_to be_routable
    end
  end
end
