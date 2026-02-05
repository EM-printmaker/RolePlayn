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
      it "バリデーションエラーになること" do
        post = build(:post, sender_session_token: nil)
        expect(post).not_to be_valid
        expect(post.errors[:sender_session_token]).to include("を入力してください")
      end
    end
  end

  describe ".character_must_belong_to_city" do
    let(:city) { create(:city) }
    let(:character) { create(:character, city: city) }
    let(:expression) { create(:expression, :with_image, character: character) }

    it "キャラクターがその街に所属していれば有効であること" do
      post = build(:post, city: city, character: character, expression: expression)
      expect(post).to be_valid
    end

    it "キャラクターが別の街に所属している場合は無効であること" do
      other_city = create(:city)
      other_character = create(:character, city: other_city)
      other_expression = create(:expression, :with_image, character: other_character)

      post = build(:post, city: city, character: other_character, expression: other_expression)
      post.city = city

      expect(post).to be_invalid
      expect(post.errors[:character]).to include(match(/がこの街に滞在していません。/))
    end
  end

  context "表情とキャラクターの整合性チェック" do
    let(:city) { create(:city) }
    let(:character) { create(:character, city: city) }
    let(:expression) { create(:expression, :with_image, character: character) }

    it "表情がそのキャラクターのものであれば有効であること" do
      post = build(:post, city: city, character: character, expression: expression)
      expect(post).to be_valid
    end

    it "表情が別のキャラクターのものである場合は無効であること" do
      other_character = create(:character, city: city)
      other_expression = create(:expression, :with_image, character: other_character)

      post = build(:post, city: city, character: character, expression: other_expression)

      expect(post).to be_invalid
      expect(post.errors[:expression]).to include(match(/指定されたキャラクターのものではありません/)) # メッセージに合わせて修正してください
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

  describe ".latest" do
    let!(:old_post) { create(:post, created_at: 1.day.ago) }
    let!(:new_post) { create(:post, created_at: 1.hour.ago) }

    it "作成日時の降順（新しい順）で取得できること" do
      expect(described_class.latest).to eq [ new_post, old_post ]
    end
  end

  describe ".sorted" do
    let!(:old_post) { create(:post, created_at: 1.day.ago) }
    let!(:new_post) { create(:post, created_at: 1.hour.ago) }

    it "引数が 'asc' の場合は昇順（古い順）になること" do
      expect(described_class.sorted("asc")).to eq [ old_post, new_post ]
    end

    it "引数が 'desc' の場合は降順（新しい順）になること" do
      expect(described_class.sorted("desc")).to eq [ new_post, old_post ]
    end

    it "引数が不正な場合（nilなど）はデフォルトで降順になること" do
      expect(described_class.sorted(nil)).to eq [ new_post, old_post ]
      expect(described_class.sorted("invalid")).to eq [ new_post, old_post ]
    end
  end

  describe ".with_details" do
    it "エラーにならず複雑なアソシエーションをプリロードできること" do
      create(:post)
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
