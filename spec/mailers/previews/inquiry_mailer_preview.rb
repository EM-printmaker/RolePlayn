# Preview all emails at http://localhost:3000/rails/mailers/inquiry_mailer
class InquiryMailerPreview < ActionMailer::Preview
  def reply
    inquiry = Inquiry.first || FactoryBot.build(:inquiry)

    subject = "【RolePlayn】お問い合わせの件につきまして"
    body = <<~BODY
      #{inquiry.name} 様

      お問い合わせありがとうございます。
      件記の件について、以下の通り回答いたします。

      内容を確認の上、ご不明な点がございましたらお知らせください。
    BODY

    InquiryMailer.reply(inquiry, subject, body)
  end
end
