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
      let(:attachment) { described_class.reflect_on_attachment(:image) }

      it "display バリアントが正しく設定されていること" do
        variant = attachment.named_variants[:display]
        expect(variant).not_to be_nil
        expect(variant.transformations).to eq(resize_to_limit: [ 400, 400 ])
      end
    end
  end

  describe "enums" do
    it "emotion_typeが正しく定義されていること(joy, angry, sad, fun, normal)" do
      expect(described_class.emotion_types.keys).to match_array(%w[joy angry sad fun normal])
    end
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
    it "エラーにならずスコープが実行できること" do
      expect { described_class.with_attached_images }.not_to raise_error
    end
  end

  describe "#find_equivalent_for(target_character)" do
    let(:character) { create(:character) }
    let(:target_character) { create(:character) }

    let(:source_expression) { create(:expression, character: character, emotion_type: "joy", level: 2) }

    context "引数が nil の場合" do
      it "nil を返すこと" do
        expect(source_expression.find_equivalent_for(nil)).to be_nil
      end
    end

    context "対象のキャラクターが全く同じ表情（emotion_type と level が一致）を持っている場合" do
      let!(:exact_match) { create(:expression, character: target_character, emotion_type: "joy", level: 2) }

      before { create(:expression, character: target_character, emotion_type: "joy", level: 1) }

      it "その表情を優先して返すこと" do
        expect(source_expression.find_equivalent_for(target_character)).to eq exact_match
      end
    end

    context "全く同じではないが、同じ emotion_type のレベル 1 を持っている場合" do
      let!(:level_1_match) { create(:expression, character: target_character, emotion_type: "joy", level: 1) }

      before { create(:expression, character: target_character, emotion_type: "fun", level: 1) }

      it "レベル 1 の同種表情を返すこと" do
        expect(source_expression.find_equivalent_for(target_character)).to eq level_1_match
      end
    end

    context "同じ emotion_type の表情を一切持っていない場合" do
      let!(:completely_different) { create(:expression, character: target_character, emotion_type: "angry", level: 1) }

      it "相手の持つ表情の中から何か（ランダムまたは最初の一つ）を返すこと" do
        expect(source_expression.find_equivalent_for(target_character)).to eq completely_different
      end
    end
  end
end
