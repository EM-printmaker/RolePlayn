require 'rails_helper'

RSpec.describe Expression, type: :model do
  subject(:expression) { create(:expression) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :character, Character
  end

  describe "image attachment" do
    let(:expression) { build(:expression, :with_image) }

    it '画像が正しくアタッチされていること' do
      expect(expression.image).to be_attached
    end

    it 'アタッチされたファイルの形式が正しいこと' do
      expect(expression.image.content_type).to eq('image/png')
    end

    context "variant :display" do
      it "リサイズ処理(resize_to_limit: [400, 400])が定義されていること"
    end
  end

  describe "enums" do
    it "emotion_typeが正しく定義されていること(joy, angry, sad, fun, normal)"
  end

  describe "deletion restrictions" do
    context "紐づく投稿が存在する場合" do
      before { create(:post, expression: expression) }

      it "削除しようとすると例外が発生して保護されること" do
        expect { expression.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context "紐づくレコードが存在しない場合" do
      let!(:expression_without_associations) { create(:expression) }

      it "正常に削除できること" do
        expect { expression_without_associations.destroy! }.to change(described_class, :count).by(-1)
      end
    end
  end

  describe ".with_attached_images" do
    it "エラーにならずスコープが実行できること"
  end
end
