require 'rails_helper'

RSpec.describe Post, type: :model do
  subject(:post) { create(:post) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :city, City
    it_behaves_like "belongs_to_association", :character, Character
    it_behaves_like "belongs_to_association", :expression, Expression
  end

  describe "#post_interval_limit" do
      let(:token) { "consistent_session_token" }

      before { create(:post, sender_session_token: token) }

      context "前回の投稿から 3 秒以内の場合" do
        it "バリデーションエラーが発生すること" do
          travel 2.seconds do
            second_post = build(:post, sender_session_token: token)
            expect(second_post).to be_invalid
            expect(second_post.errors[:base]).to include(/あと \d+ 秒でまたお話しできます/)
          end
        end
      end

      context "前回の投稿から 3 秒経過している場合" do
        it "正常に投稿できること" do
          travel 4.seconds do
            second_post = build(:post, sender_session_token: token)
            expect(second_post).to be_valid
          end
        end
      end

      context "トークンが異なる場合" do
        it "3 秒以内でも別々のユーザー（トークン）なら投稿できること" do
          travel 1.second do
            other_user_post = build(:post, sender_session_token: "different_token")
            expect(other_user_post).to be_valid
          end
        end
      end

      context "トークンが空の場合" do
        it "制限をスキップして投稿できること" do
          travel 1.second do
            no_token_post = build(:post, sender_session_token: nil)
            expect(no_token_post).to be_valid
          end
        end
      end
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

  describe ".with_details" do
    it "エラーにならず複雑なアソシエーションをプリロードできること" do
      create(:post, :with_full_data)
      expect { described_class.with_details.to_a }.not_to raise_error
    end
  end

  describe "#broadcast_new_post_notification" do
    let(:city) { create(:city) }
    let(:character) { create(:character, city: city) }
    let(:expression) { create(:expression, :with_image, character: character) }
    let(:token) { "test_session_token_123" }
    let(:post) { build(:post, city: city, character: character, expression: expression, sender_session_token: token) }

    it "通知が正しい内容でブロードキャストされること" do
      skip "ブロードキャスト一時停止中のため"
      expect {
        post.save!
      }.to(have_broadcasted_to("posts_channel_city_#{city.id}").with { |data|
        expect(data).to include('target="new-posts-alert"')
        expect(data).to include(token)
      })
    end
  end
end
