require 'rails_helper'

RSpec.describe City, type: :model do
  subject(:city) { create(:city) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :world, World
    it_behaves_like "has_many_association", :characters, :character, :city
    it_behaves_like "has_many_association", :posts, :post, :city
  end

  describe "deletion restrictions" do
    context "紐づくキャラクターが存在する場合" do
      before { create(:character, city: city) }

      it "削除しようとすると例外が発生して保護されること" do
        expect { city.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context "紐づく投稿が存在する場合" do
      before { create(:post, city: city) }

      it "削除しようとすると例外が発生して保護されること" do
        expect { city.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context "紐づくレコードが存在しない場合" do
      let!(:city_without_associations) { create(:city) }

      it "正常に削除できること" do
        expect { city_without_associations.destroy! }.to change(described_class, :count).by(-1)
      end
    end
  end
end
