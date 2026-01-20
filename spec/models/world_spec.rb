require 'rails_helper'

RSpec.describe World, type: :model do
  describe 'associations' do
    context "紐づく街が存在する場合" do
      let(:world) { create(:world) }
      let!(:city) { create(:city, world: world) }

      it "紐づくCityが含まれていること" do
        expect(world.cities).to include city
      end

      it "削除しようとすると例外が発生して保護されること" do
        expect { world.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context "紐づく街が存在しない場合" do
      let!(:world) { create(:world) }

      it "正常に削除できること" do
        expect { world.destroy! }.to change(described_class, :count).by(-1)
      end
    end
  end
end
