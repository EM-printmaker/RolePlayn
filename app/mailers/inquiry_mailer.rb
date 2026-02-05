class InquiryMailer < ApplicationMailer
  def reply(inquiry, subject, body)
    @body = body
    @inquiry = inquiry

    mail(
      to: @inquiry.email,
      subject: subject
    )
  end
end
