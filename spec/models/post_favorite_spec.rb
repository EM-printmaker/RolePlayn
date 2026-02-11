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

  describe "#notify_post_author" do
    let(:author) { create(:user, unread_notification: false) }
    let(:visitor) { create(:user) }
    let(:post) { create(:post, user: author) }

    it "投稿者の通知フラグ(unread_notification)がtrueに更新されること" do
      expect {
        create(:post_favorite, user: visitor, post: post)
      }.to change(author, :unread_notification).from(false).to(true)
    end

    it "自分の投稿の場合は変化させないこと" do
      expect {
        create(:post_favorite, user: author, post: post)
      }.not_to change(author, :unread_notification)
    end
  end
end
