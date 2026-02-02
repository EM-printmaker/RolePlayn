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

  describe ".pick_random (RandomSelectable)" do
    before { create_list(:character, 2) }

    it "登録されているキャラクターから 1 件が取得されること" do
      result = described_class.pick_random
      expect(result).to be_a(described_class)
      expect(result).not_to be_nil
    end
  end

  describe "#primary_observer" do
    let(:world) { create(:world) }
    let(:city) { create(:city, world: world) }
    let(:observer_city) { create(:city, :observer, target_world_id: world.id) }
    let(:character) { create(:character, city: city) }

    before { observer_city }

    it "所属する世界の観測用Cityを返すこと" do
      expect(character.primary_observer).to eq observer_city
    end

    context "世界の観測用Cityが存在しない場合" do
      before { observer_city.delete }

      it "nilを返すこと" do
        expect(character.primary_observer).to be_nil
      end
    end
  end

  describe "#main_image" do
    let(:character) { create(:character) }

    context "level 1 で normal な表情がある場合" do
      let!(:normal_expression) { create(:expression, character: character, emotion_type: "normal", level: 1) }

      it "その表情の画像を返すこと" do
        expect(character.main_image).to eq normal_expression.image
      end
    end

    context "level 1 / normal な表情がない場合" do
      let!(:other_expressions) { create_list(:expression, 2, :with_image, character: character) }

      it "最初に登録された表情の画像を返すこと" do
        expect(character.main_image).to eq other_expressions.first.image
      end
    end

    context "表情が1つもない場合" do
      it "nilを返すこと" do
        expect(character.main_image).to be_nil
      end
    end
  end

  describe "#match_expression" do
    let(:character) { create(:character) }
    let!(:joy_expression) { create(:expression, character: character, emotion_type: "joy") }
    let(:template) { instance_double(Expression) }

      it "同種の表情を返すこと" do
        allow(template).to receive(:find_equivalent_for).with(character).and_return(joy_expression)
        expect(character.match_expression(template)).to eq joy_expression
      end

    context "同種の表情を持っていない、またはテンプレートが nil の場合" do
      it "自身の表情からランダムに1つ返すこと" do
        expect(character.match_expression(nil)).to eq joy_expression
      end
    end
  end
end
