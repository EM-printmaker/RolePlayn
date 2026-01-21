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
end
