class Avo::Actions::ReplyToInquiry < Avo::BaseAction
  self.name = "内容を確認して送信"
  self.message = "以下の内容で返信メールを送信します。よろしいですか？"
  self.confirm_button_label = "送信する"

  def fields
    field :from_display, as: :text, name: "From",
          default: "RolePlayn サポート <#{ENV['MAIL_FROM_ADDRESS']}>",
          readonly: true
    field :target, as: :text, name: "To", default: "#{record.name} 様 (#{record.email})", readonly: true
    field :subject, as: :text, name: "件名", default: record.reply_subject, readonly: true
    field :body, as: :textarea, name: "本文", default: record.reply_body, rows: 10, readonly: true
  end

  def handle(query:, **_args)
    query.each do |record|
      if record.reply_body.blank? || record.reply_subject.blank?
        error "ID:#{record.id} の返信内容が空です。先に返信案を作成してください。"
        next
      end
      InquiryMailer.reply(record, record.reply_subject, record.reply_body).deliver_later
      record.update!(
        status: :completed,
        reply_sent_at: Time.current,
      )
      succeed "返信メールを送信し、ステータスを『完了』にしました。"
    end
  end
end
