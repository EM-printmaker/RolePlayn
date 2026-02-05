require 'rails_helper'

RSpec.describe Inquiry, type: :model do
  describe "#user" do
    it "Userモデルに任意で属していること" do
      inquiry = build(:inquiry, user: nil)
      expect(inquiry).to be_valid
    end
  end

  describe "#related_inquiries" do
    let(:user) { create(:user) }
    let!(:inquiry) { create(:inquiry, user: user) }
    let!(:same_user_inquiry) { create(:inquiry, user: user) }
    let!(:other_inquiry) { create(:inquiry, user: create(:user)) }

    it "同じuser_idを持つ他のお問い合わせを全て取得できること" do
      expect(inquiry.related_inquiries).to include(same_user_inquiry)
      expect(inquiry.related_inquiries).not_to include(other_inquiry)
    end
  end

  describe "#status" do
    it "デフォルト値が unread であること" do
      expect(described_class.new.status).to eq 'unread'
    end
  end

  describe "#category" do
    it "デフォルト値が bug_report であること" do
      expect(described_class.new.category).to eq 'bug_report'
    end
  end

  describe "#inquiry_interval_limit" do
    let(:email) { "test@example.com" }

    before { create(:inquiry, email: email) }

    context "同じメールアドレスから2分以内に投稿しようとした場合" do
      it "バリデーションエラーが発生すること" do
        travel 1.minute do
          new_inquiry = build(:inquiry, email: email)
          expect(new_inquiry).to be_invalid
          expect(new_inquiry.errors[:base]).to include(I18n.t('activerecord.errors.models.inquiry.attributes.base.too_soon'))
        end
      end
    end

    it "2分経過していれば正常に投稿できること" do
      travel 3.minutes do
        new_inquiry = build(:inquiry, email: email)
        expect(new_inquiry).to be_valid
      end
    end
  end
end
