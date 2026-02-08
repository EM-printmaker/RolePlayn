require "rails_helper"

RSpec.describe InquiryMailer, type: :mailer do
  describe "reply" do
    let(:inquiry) { create(:inquiry) }
    let(:subject_text) { "【RolePlayn】お問い合わせの回答" }
    let(:body_text) { "お問い合わせありがとうございます。内容を確認いたしました。" }
    let(:mail) { described_class.reply(inquiry, subject_text, body_text) }

    before do
      stub_const("ENV", ENV.to_hash.merge("MAIL_FROM_ADDRESS" => "support@example.com"))
    end

    it "ヘッダー情報（宛先・送信元・件名）が正しいこと" do
      expect(mail.to).to eq([ inquiry.email ])
      expect(mail.from).to eq([ "support@example.com" ])
      expect(mail.subject).to eq(subject_text)
    end

    it "本文に引数で渡したメッセージが含まれていること" do
      if mail.multipart?
        expect(mail.text_part.decoded).to include(body_text)
        expect(mail.html_part.decoded).to include(body_text)
      else
        expect(mail.body.decoded).to include(body_text)
      end
    end
  end
end
