require 'rails_helper'

RSpec.describe World, type: :model do
  subject(:world) { create(:world) }

  describe "associations" do
    it_behaves_like "has_many_association", :cities, :city, :world
  end

  describe "deletion restrictions" do
    context "紐づく街が存在する場合" do
      before { create(:city, world: world) }

      it "削除しようとすると例外が発生して保護されること" do
        expect { world.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context "紐づく街が存在しない場合" do
      let!(:world_without_associations) { create(:world) }

      it "正常に削除できること" do
        expect { world_without_associations.destroy! }.to change(described_class, :count).by(-1)
      end
    end
  end

  describe "#slug(HasSlug)" do
    it "除外した文字列を使用すると保存に失敗すること" do
      invalid_world = build(:world, slug: "new")
      expect(invalid_world).not_to be_valid
    end
  end

  describe "is_global" do
    let!(:global_world) { create(:world, is_global: true) }
    let!(:local_world)  { create(:world, is_global: false) }

    it "global スコープが is_global: true のレコードのみを返すこと" do
      expect(described_class.global).to include(global_world)
      expect(described_class.global).not_to include(local_world)
    end

    it "local スコープが is_global: false のレコードのみを返すこと" do
      expect(described_class.local).to include(local_world)
      expect(described_class.local).not_to include(global_world)
    end

    context "is_global が true の場合" do
      subject(:world) { build(:world, is_global: true) }

      it "global? が true を返すこと" do
        expect(world.global?).to be true
      end

      it "local? が false を返すこと" do
        expect(world.local?).to be false
      end
    end

    context "is_global が false の場合" do
      subject(:world) { build(:world, is_global: false) }

      it "local? が true を返すこと" do
        expect(world.local?).to be true
      end

      it "global? が false を返すこと" do
        expect(world.global?).to be false
      end
    end
  end

  describe "#observation_city" do
    let!(:first_city) { create(:city, :global) }
    let!(:observer_city) { create(:city, :observer, target_world_id: world.id) }
    let!(:isolated_world) { create(:world) }

    it "自身を観測対象としている街(node)を返すこと" do
      expect(world.observation_city).to eq observer_city
    end

    it "自身を観測対象としている街がない場合、最初のグローバルな都市を返すこと" do
      expect(isolated_world.observation_city).to eq first_city
    end
  end
end
