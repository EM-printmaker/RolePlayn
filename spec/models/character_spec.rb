require 'rails_helper'

RSpec.describe Character, type: :model do
  describe 'associations' do
    let(:character) { create(:character) }
    let!(:expression) { create(:expression, character: character) }

    it "Cityに属していること" do
      expect(character.city).to be_a(City)
    end

    it "紐づくExpressionが含まれていること" do
      expect(character.expressions).to include expression
    end

    context "削除された場合" do
      it "紐づくexpressionも削除されること" do
        expect { character.destroy }.to change(Expression, :count).by(-1)
      end
    end
  end
end
