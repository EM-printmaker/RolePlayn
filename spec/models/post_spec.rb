require 'rails_helper'

RSpec.describe Post, type: :model do
  subject(:post) { create(:post) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :city, City
    it_behaves_like "belongs_to_association", :character, Character
    it_behaves_like "belongs_to_association", :expression, Expression
  end

  describe ".from_local_worlds" do
    it "ローカルな世界（is_global: false）の街からの投稿のみを返すこと"
    it "グローバルな世界の街からの投稿は含まれないこと"
  end

  describe ".from_world" do
    it "指定されたWorld IDに属する街の投稿のみを返すこと"
  end

  describe ".from_city" do
    it "指定されたCity IDの投稿のみを返すこと"
  end

  describe "#broadcast_new_post_notification" do
    it "投稿作成後に、'posts_channel' へ通知がブロードキャストされること"
    it "ブロードキャストのターゲットが 'new-posts-alert' であること"
    it "ブロードキャストの locals に sender_session_token が正しく含まれていること"
  end
end
