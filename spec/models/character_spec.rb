require 'rails_helper'

RSpec.describe Character, type: :model do
  subject(:character) { create(:character) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :city, City
    it_behaves_like "has_many_association", :expressions, :expression, :character
  end

  describe "deletion restrictions" do
    context "紐づく投稿が存在する時" do
      before { create(:post, character: character) }

      it "削除しようとすると例外が発生して保護されること" do
        expect { character.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context "紐づくレコードが存在しない場合" do
      let!(:character_without_associations) { create(:character) }

      it "正常に削除できること" do
        expect { character_without_associations.destroy! }.to change(described_class, :count).by(-1)
      end
    end

    context "削除された場合" do
      before { create(:expression, character: character) }

      it "紐づくexpressionも削除されること" do
        expect { character.destroy! }.to change(Expression, :count).by(-1)
      end
    end
  end
end
