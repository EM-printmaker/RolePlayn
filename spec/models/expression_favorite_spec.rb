require 'rails_helper'

RSpec.describe ExpressionFavorite, type: :model do
  subject(:expression_favorite) { create(:expression_favorite) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :user, User
    it_behaves_like "belongs_to_association", :expression, Expression
  end

  describe "validations" do
    let(:user) { create(:user) }
    let(:expression) { create(:expression) }

    before { create(:expression_favorite, user: user, expression: expression) }

    it "同じユーザー・同じ表情の組み合わせは重複して登録できないこと" do
      duplicate = build(:expression_favorite,
          user: user,
          expression: expression
        )
      expect(duplicate).to be_invalid
      expect(duplicate.errors[:user_id]).to include("はすでに存在します")
    end
  end
end
