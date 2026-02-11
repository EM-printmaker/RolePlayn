require 'rails_helper'

RSpec.describe CharacterAssignment, type: :model do
  subject(:character_assignment) { create(:character_assignment) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :user, User
    it_behaves_like "belongs_to_association", :city, City
    it_behaves_like "belongs_to_association", :character, Character
    it_behaves_like "belongs_to_association", :expression, Expression
  end

  # describe "associations" の直後あたりに追加
  describe "validations" do
    let(:city) { create(:city) }
    let(:character) { create(:character, city: city) }
    let(:expression) { create(:expression, :with_image, character: character) }

    context "データの整合性 (associations_consistency)" do
      it "Characterが指定されたCityに所属していない場合、無効であること" do
        other_city = create(:city)
        assignment = build(:character_assignment, city: other_city, character: character, expression: expression)

        expect(assignment).to be_invalid
        expect(assignment.errors[:character]).to include(match(/はこの都市に所属していません/))
      end

      it "Expressionが指定されたCharacterのものではない場合、無効であること" do
        other_character = create(:character, city: city)
        other_expression = create(:expression, :with_image, character: other_character)

        assignment = build(:character_assignment, city: city, character: character, expression: other_expression)

        expect(assignment).to be_invalid
        expect(assignment.errors[:expression]).to include(match(/表情ではありません/))
      end
    end

    context "一意性制約" do
      let(:user) { create(:user) }
      let(:assigned_character) { create(:character, city: city) }
      let(:assigned_expression) { create(:expression, :with_image, character: assigned_character) }

      before do
        create(:character_assignment,
          user: user,
          city: city,
          character: assigned_character,
          expression: assigned_expression,
          assigned_date: Time.zone.today
        )
      end

      it "同じユーザー・同じ都市・同じ日付の組み合わせは重複して登録できないこと" do
          duplicate = build(:character_assignment,
          user: user,
          city: city,
          character: assigned_character,
          expression: assigned_expression,
          assigned_date: Time.zone.today
        )
        expect(duplicate).to be_invalid
        expect(duplicate.errors[:assigned_date]).to include(match(/はすでに存在します/))
      end
    end
  end

  describe ".for_viewing" do
    let(:user) { create(:user) }
    let(:city) { create(:city) }
    let(:character) { create(:character, city: city) }
    let!(:today_assignment) do
      create(:character_assignment, user: user, city: city, character: character, assigned_date: Time.zone.today)
    end

    it "指定されたユーザーと街の、今日の配役を返すこと" do
      expect(described_class.for_viewing(user, city)).to eq today_assignment
    end

    it "日付が異なる配役は返さないこと" do
      travel_to 1.day.from_now do
        expect(described_class.for_viewing(user, city)).to be_nil
      end
    end

    it "引数が nil の場合に nil を返すこと" do
      expect(described_class.for_viewing(nil, city)).to be_nil
    end
  end

  describe ".exists_for_today?" do
    let(:user) { create(:user) }
    let(:city) { create(:city) }
    let(:character) { create(:character, city: city) }

    context "今日の配役が存在する場合" do
      before { create(:character_assignment, user: user, city: city, character: character, assigned_date: Time.zone.today) }

      it "true を返すこと" do
        expect(described_class.exists_for_today?(user, city)).to be true
      end
    end

    context "今日の配役が存在しない場合" do
      it "false を返すこと" do
        expect(described_class.exists_for_today?(user, city)).to be false
      end
    end

    context "引数が不完全な場合" do
      it "false を返すこと" do
        expect(described_class.exists_for_today?(nil, city)).to be false
        expect(described_class.exists_for_today?(user, nil)).to be false
      end
    end
  end

  describe ".ensure_for_today!" do
    let(:user) { create(:user) }
    let(:city) { create(:city) }

    before do
      create_list(:character, 3, :with_expressions, city: city)
    end

    it "新しくレコードが作成されること" do
      expect {
        described_class.ensure_for_today!(user, city)
      }.to change(described_class, :count).by(1)
    end

    it "前日の配役が存在する場合、そのキャラクターは除外して抽選されること" do
      old_character = city.characters.first
      create(:character_assignment,
        user: user, city: city, character: old_character, assigned_date: 1.day.ago)

      10.times do
        assignment = described_class.ensure_for_today!(user, city)
        expect(assignment.character).not_to eq old_character
      end
    end

    context "今日の配役が既に存在する場合" do
      let!(:existing) do
        create(:character_assignment,
          user: user,
          city: city,
          character: city.characters.first,
          assigned_date: Time.zone.today
        )
      end

      it "新しいレコードは作られず、既存のレコードを返すこと" do
        expect {
          result = described_class.ensure_for_today!(user, city)
          expect(result).to eq existing
        }.not_to change(described_class, :count)
      end
    end
  end

describe "#shuffle!" do
    let(:city) { create(:city) }
    let!(:current_character) { create(:character, :with_expressions, city: city) }
    let!(:other_characters) { create_list(:character, 2, :with_expressions, city: city) }

    let(:assignment) do
      create(:character_assignment, city: city, character: current_character, expression: current_character.expressions.first)
    end

    it "キャラクターが別のキャラに更新されること" do
      expect { assignment.shuffle! }.to change(assignment, :character_id)
      expect(other_characters.map(&:id)).to include(assignment.character_id)
      expect(assignment.expression.character_id).to eq assignment.character_id
    end
  end

describe "#switch_character!" do
    let(:city) { create(:city) }
    let(:current_character) { create(:character, :with_expressions, city: city) }
    let(:new_character) { create(:character, :with_expressions, city: city) }

    let(:assignment) do
      create(:character_assignment, city: city, character: current_character, expression: current_character.expressions.first)
    end

    it "指定されたキャラクターに更新され、表情も適切に引き継がれること" do
      expect {
        assignment.switch_character!(new_character)
      }.to change(assignment, :character_id).from(current_character.id).to(new_character.id)

      expect(assignment.expression.character).to eq new_character
    end
  end

  describe "#change_expression!" do
    let(:character) { create(:character) }
    let!(:old_expression) { create(:expression, :with_image, character: character) }
    let!(:new_expression) { create(:expression, :with_image, :joy, character: character) }

    let(:assignment) do
      create(:character_assignment, character: character, expression: old_expression)
    end

    it "表情が更新されること" do
      expect {
        assignment.change_expression!(new_expression)
      }.to change(assignment, :expression_id).from(old_expression.id).to(new_expression.id)
    end
  end

  describe ".transfer_from_guest!" do
    let(:user) { create(:user) }
    let(:city) { create(:city) }
    let(:character) { create(:character, city: city) }
    let(:expression) { create(:expression, :with_image, character: character) }
    let(:guest_assignments) do
      {
        city.id.to_s => {
          "character_id" => character.id,
          "expression_id" => expression.id,
          "assigned_date" => Time.zone.today.to_s
        }
      }
    end

    it "ゲストセッションのデータがDBに正しく移行されること" do
      expect {
        described_class.transfer_from_guest!(user, guest_assignments)
      }.to change(described_class, :count).by(1)

      assignment = described_class.last
      expect(assignment.user).to eq user
      expect(assignment.character_id).to eq character.id
      expect(assignment.assigned_date).to eq Time.zone.today
    end

    it "既に同じ日のデータがある場合は重複して作成されないこと" do
      create(:character_assignment,
        user: user,
        city: city,
        character: character,
        expression: expression,
        assigned_date: Time.zone.today
      )

      expect {
        described_class.transfer_from_guest!(user, guest_assignments)
      }.not_to change(described_class, :count)
    end

    it "ハッシュが空の場合は何もしないこと" do
      expect {
        described_class.transfer_from_guest!(user, {})
      }.not_to change(described_class, :count)
    end
  end
end
