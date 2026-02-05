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

  describe "#city / #world (delegation)" do
    let(:world) { create(:world) }
    let(:city) { create(:city, world: world) }
    let(:character) { create(:character, city: city) }
    let(:expression) { create(:expression, :with_image, character: character) }

    it "characterを経由してcityを取得できること" do
      expect(expression.city).to eq city
    end

    it "characterを経由してworldを取得できること" do
      expect(expression.world).to eq world
    end
  end

  describe "enums" do
    it "emotion_typeが正しく定義されていること(joy, angry, sad, fun, normal)" do
      expect(described_class.emotion_types.keys).to match_array(%w[joy angry sad fun normal])
    end
  end

  describe "deletion restrictions" do
    context "紐づく投稿が存在する場合" do
      before do
        create(:post,
          expression: expression,
          character: expression.character,
          city: expression.character.city
        )
      end

      it "削除しようとすると例外が発生して保護されること" do
        expect { expression.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context "紐づくCharacterAssignmentが存在する場合" do
      let(:character) { create(:character) }
      let(:expression) { create(:expression, :with_image, character: character) }

      before do
        create(:character_assignment,
          character: character,
          city: character.city,
          expression: expression
        )
      end

      it "Expression削除時にAssignmentも削除されること" do
        expect { expression.destroy }.to change(CharacterAssignment, :count).by(-1)
      end
    end

    context "紐づくレコードが存在しない場合" do
      let!(:expression_without_associations) { create(:expression) }

      it "正常に削除できること" do
        expect { expression_without_associations.destroy! }.to change(described_class, :count).by(-1)
      end
    end
  end

  describe "validations (uniqueness)" do
    let(:character) { create(:character) }

    before { create(:expression, :with_image, character: character, emotion_type: :joy, level: 1) }

    context "同じキャラクター・同じ感情タイプ・同じレベルの場合" do
      it "重複して登録できないこと" do
        duplicate = build(:expression, :with_image, character: character, emotion_type: :joy, level: 1)
        expect(duplicate).to be_invalid
        expect(duplicate.errors[:level]).to include(match(/登録されています/))
      end
    end

    it "同じキャラクター・同じ感情タイプでもレベルが異なれば登録できること" do
      diff_level = build(:expression, :with_image, character: character, emotion_type: :joy, level: 2)
      expect(diff_level).to be_valid
    end

    it "別のキャラクターであれば同じ感情・同じレベルでも登録できること" do
      other_char = create(:character)
      other_expression = build(:expression, :with_image, character: other_char, emotion_type: :joy, level: 1)
      expect(other_expression).to be_valid
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

  describe "#display_name" do
    let(:character) { create(:character, name: "テスト") }
    let(:expression) { create(:expression, :with_image, character: character, emotion_type: :joy, level: 2) }

    it "キャラクター名と感情タイプとレベルを含む文字列を返すこと" do
      expect(expression.display_name).to eq "テスト - joy (Lv.2)"
    end

    context "キャラクターが存在しない場合" do
      before { expression.character = nil }

      it "感情タイプとレベルのみの文字列を返すこと" do
        expect(expression.display_name).to eq "joy (Lv.2)"
      end
    end
  end
end
