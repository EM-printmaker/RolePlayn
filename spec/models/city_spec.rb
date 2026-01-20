require 'rails_helper'

RSpec.describe City, type: :model do
  describe 'associations' do
    let(:city) { create(:city) }

    it "Worldに属していること" do
      expect(city.world).to be_a(World)
    end

    context "紐づくキャラクターが存在する場合" do
      let!(:character) { create(:character, city: city) }

      it "紐づくCharacterが含まれていること" do
        expect(city.characters).to include character
      end

      it "削除しようとすると例外が発生して保護されること" do
        expect { city.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context "紐づくキャラクターが存在しない場合" do
      let!(:city) { create(:city) }

      it "正常に削除できること" do
        expect { city.destroy! }.to change(described_class, :count).by(-1)
      end
    end
  end
end
