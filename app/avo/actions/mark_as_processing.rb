class Avo::Actions::MarkAsProcessing < Avo::BaseAction
  self.name = "対応中にする"
  # self.visible = -> do
  #   true
  # end

  # def fields
  #   # Add Action fields here
  # end
  self.message = "ステータスを対応中に変更します。"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    query.each do |record|
      record.processing!
    end
    succeed "ステータスを『対応中』に更新しました。"
  end
end
