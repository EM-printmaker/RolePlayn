class Avo::Actions::PrepareReply < Avo::BaseAction
  self.name = "返信の内容を作成"
  # self.visible = -> do
  #   true
  # end

  def fields
    field :reply_subject, as: :text, name: "返信件名", default: "【RolePlayn】お問い合わせの件につきまして"
    field :reply_body, as: :textarea, name: "返信本文", rows: 10
  end

  def handle(query:, fields:, _current_user:, _resource:, **_args)
    query.each do |record|
      record.update!(
        reply_subject: fields[:reply_subject],
        reply_body: fields[:reply_body],
        status: :processing
      )
    end
    succeed "返信案を保存しました。内容を確認して送信してください。"
  end
end
