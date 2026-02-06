class Avo::Actions::MarkAsProcessing < Avo::BaseAction
  self.name = "対応中にする"
  self.message = "ステータスを対応中に変更します。"

  def handle(query:, **_args)
    query.each do |record|
      record.processing!
    end
    succeed "ステータスを『対応中』に更新しました。"
  end
end
