require 'rails_helper'

RSpec.describe PostFavorite, type: :model do
  subject(:post_favorite) { create(:post_favorite) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :user, User
    it_behaves_like "belongs_to_association", :post, Post
  end

  describe "validations" do
    let(:user) { create(:user) }
    let(:post) { create(:post) }

    before { create(:post_favorite, user: user, post: post) }

    it "同じユーザー・同じ投稿の組み合わせは重複して登録できないこと" do
      duplicate = build(:post_favorite,
          user: user,
          post: post
        )
      expect(duplicate).to be_invalid
      expect(duplicate.errors[:user_id]).to include("はすでに存在します")
    end
  end
end
