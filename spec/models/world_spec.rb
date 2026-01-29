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
    it "除外した文字列を使用すると保存に失敗すること"
  end

  describe "is_global" do
    it "global スコープが is_global: true のレコードのみを返すこと"
    it "local スコープが is_global: false のレコードのみを返すこと"
    it "is_global が true のとき、global? が true を返すこと"
    it "is_global が false のとき、local? が true を返すこと"
  end

  describe "#observation_city" do
    it "自身を観測対象としている街(node)を返すこと"
    it "自身を観測対象としている街がない場合、ID順で最初の都市を返すこと"
  end
end
