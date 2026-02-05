require 'rails_helper'

RSpec.describe CharacterAssignment, type: :model do
  subject(:character_assignment) { create(:character_assignment) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :user, User
    it_behaves_like "belongs_to_association", :city, City
    it_behaves_like "belongs_to_association", :character, Character
    it_behaves_like "belongs_to_association", :expression, Expression
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
