require 'rails_helper'

RSpec.describe Post, type: :model do
  subject(:post) { create(:post) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :city, City
    it_behaves_like "belongs_to_association", :character, Character
    it_behaves_like "belongs_to_association", :expression, Expression
  end

  describe ".from_local_worlds" do
    let!(:local_post) { create(:post) }
    let(:global_city) { create(:city, :global) }
    let!(:global_post) { create(:post, city: global_city) }

    it "ローカルな世界（is_global: false）の街からの投稿のみを返すこと" do
      expect(described_class.from_local_worlds).to include(local_post)
      expect(described_class.from_local_worlds).not_to include(global_post)
    end
  end

  describe ".from_world" do
    let(:city) { create(:city) }
    let!(:post) { create(:post, city: city) }
    let!(:other_city_post) { create(:post) }

    it "指定されたWorld IDに属する街の投稿のみを返すこと" do
      expect(described_class.from_world(city.world)).to include(post)
      expect(described_class.from_world(city.world)).not_to include(other_city_post)
    end
  end

  describe ".from_city" do
    let(:city) { create(:city) }
    let!(:post) { create(:post, city: city) }
    let!(:other_city_post) { create(:post) }

    it "指定されたCity IDの投稿のみを返すこと" do
      expect(described_class.from_city(city)).to include(post)
      expect(described_class.from_city(city)).not_to include(other_city_post)
    end
  end

  describe "#broadcast_new_post_notification" do
    let(:token) { "test_session_token_123" }
    let(:post) { build(:post, sender_session_token: token) }

  it "通知が正しい内容でブロードキャストされること" do
    expect {
      post.save!
    }.to(have_broadcasted_to("posts_channel").with { |data|
      expect(data).to include('target="new-posts-alert"')
      expect(data).to include(token)
    })
  end
  end
end
