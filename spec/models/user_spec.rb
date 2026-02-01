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
        expect(user.errors[:login_id]).to include('は3文字以上で入力してください')
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
        expect(duplicate_user.errors[:login_id]).to include('はすでに存在します')
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
end
