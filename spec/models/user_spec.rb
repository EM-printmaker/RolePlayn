require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe "#login_id" do
    it '空（nil または空文字）でも初期登録時は有効であること' do
        user.login_id = nil
        expect(user).to be_valid
        user.login_id = ''
        expect(user).to be_valid
    end

    context '異常系の場合' do
      it '3文字未満なら無効であること' do
        user.login_id = 'ab'
        expect(user).to be_invalid
        expect(user.errors[:login_id]).to include('は3文字以上で入力してください。')
      end

      it '20文字を超えるなら無効であること' do
        user.login_id = 'a' * 21
        expect(user).to be_invalid
      end

      it '許可されていない記号（ハイフンなど）が含まれるなら無効であること' do
        user.login_id = 'user-id'
        expect(user).to be_invalid
      end

      it 'スペースが含まれるなら無効であること' do
        user.login_id = 'user id'
        expect(user).to be_invalid
      end

      it '重複した login_id は無効であること（大文字小文字を区別しない）' do
        create(:user, login_id: 'unique_user')
        duplicate_user = build(:user, login_id: 'UNIQUE_USER')

        expect(duplicate_user).to be_invalid
        expect(duplicate_user.errors[:login_id]).to include('はすでに使用されています。')
      end

      it '予約語（例: admin）は使用できないこと' do
        user.login_id = 'admin'
        expect(user).to be_invalid
        expect(user.errors[:login_id]).to be_present
      end

      it '数字のみの login_id は無効であること' do
        user.login_id = '123456'
        expect(user).to be_invalid
        expect(user.errors[:login_id]).to include(match(/数字のみ/))
      end

      it 'アンダースコアで始まる場合は無効であること' do
        user.login_id = '_username'
        expect(user).to be_invalid
      end

      it 'アンダースコアで終わる場合は無効であること' do
        user.login_id = 'username_'
        expect(user).to be_invalid
      end
    end
  end

  describe 'role' do
    it 'デフォルト値が general であること' do
      new_user = described_class.new
      expect(new_user.role).to eq 'general'
    end
  end

  describe '.downcase_login_id' do
    it 'バリデーション前に login_id を小文字に変換すること' do
      user.login_id = 'MixedCase_ID'
      user.valid?
      expect(user.login_id).to eq 'mixedcase_id'
    end
  end

  describe '#can_access_admin?' do
    it 'admin権限を持つユーザーは true を返すこと' do
      user.role = :admin
      expect(user.can_access_admin?).to be true
    end

    it 'moderator権限を持つユーザーは true を返すこと' do
      user.role = :moderator
      expect(user.can_access_admin?).to be true
    end

    it 'general権限を持つユーザーは false を返すこと' do
      user.role = :general
      expect(user.can_access_admin?).to be false
    end
  end

  describe '.find_first_by_auth_conditions' do
    let!(:target_user) { create(:user, login_id: 'target_user', email: 'target@example.com') }

    it 'login_id でユーザーを検索できること（大文字小文字無視）' do
      conditions = { login: 'TARGET_USER' }
      result = described_class.find_first_by_auth_conditions(conditions)
      expect(result).to eq target_user
    end

    it 'email でユーザーを検索できること（大文字小文字無視）' do
      conditions = { login: 'TARGET@EXAMPLE.COM' }
      result = described_class.find_first_by_auth_conditions(conditions)
      expect(result).to eq target_user
    end

    it '条件に一致しない場合は nil を返すこと' do
      conditions = { login: 'unknown_user' }
      result = described_class.find_first_by_auth_conditions(conditions)
      expect(result).to be_nil
    end
  end

  describe "#favorited_post?" do
    let(:post) { create(:post) }

    context "指定した投稿をお気に入りしている場合" do
      before do
        create(:post_favorite, user: user, post: post)
      end

      it "trueを返すこと" do
        expect(user.favorited_post?(post)).to be true
      end
    end

    context "指定した投稿をお気に入りしていない場合" do
      it "falseを返すこと" do
        expect(user.favorited_post?(post)).to be false
      end
    end

    context "引数がnilの場合" do
      it "falseを返すこと" do
        expect(user.favorited_post?(nil)).to be false
      end
    end
  end

  describe "#favorited_expression?" do
    let(:expression) { create(:expression) }

    context "指定した表情をお気に入りしている場合" do
      before do
        create(:expression_favorite, user: user, expression: expression)
      end

      it "trueを返すこと" do
        expect(user.favorited_expression?(expression)).to be true
      end
    end

    context "指定した表情をお気に入りしていない場合" do
      it "falseを返すこと" do
        expect(user.favorited_expression?(expression)).to be false
      end
    end
  end

  describe "#mark_notifications_as_read" do
    let(:logged_in_user) { create(:user, unread_notification: true) }

    it "unread_notificationをfalseにすること" do
      expect { logged_in_user.mark_notifications_as_read }
        .to change(logged_in_user, :unread_notification)
        .from(true).to(false)
    end
  end

  describe '#active_for_authentication?' do
    it 'true を返すこと' do
      user.suspended_at = nil
      expect(user.active_for_authentication?).to be true
    end

    context 'suspended_at に日時が入っている場合' do
      it 'false を返すこと' do
        user.suspended_at = Time.current
        expect(user.active_for_authentication?).to be false
      end
    end
  end

  describe '#inactive_message' do
    context '凍結されている場合' do
      it ':suspended を返すこと' do
        user.suspended_at = Time.current
        expect(user.inactive_message).to eq :suspended
      end
    end

    context '凍結されておらず、ロックされている場合' do
      it ':locked を返すこと' do
        user.suspended_at = nil
        allow(user).to receive(:access_locked?).and_return(true)
        expect(user.inactive_message).to eq :locked
      end
    end
  end
end
