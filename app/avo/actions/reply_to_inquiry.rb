class Avo::Actions::ReplyToInquiry < Avo::BaseAction
  self.name = "内容を確認して送信"
  # self.visible = -> do
  #   true
  # end
  self.message = "以下の内容で返信メールを送信します。よろしいですか？"
  self.confirm_button_label = "送信する"

  def fields
    field :target, as: :text, name: "送信先", default: "#{record.name} 様 (#{record.email})", readonly: true
    field :subject, as: :text, name: "件名", default: record.reply_subject, readonly: true
    field :body, as: :textarea, name: "本文", default: record.reply_body, rows: 10, readonly: true
  end

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    query.each do |record|
      InquiryMailer.reply(record, record.reply_subject, record.reply_body).deliver_later
      record.update!(
        status: :completed,
        reply_sent_at: Time.current,
      )
    end
    succeed "返信メールを送信し、ステータスを『完了』にしました。"
  end
end
