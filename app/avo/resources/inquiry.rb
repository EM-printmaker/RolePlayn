class Avo::Resources::Inquiry < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field "基本情報", as: :heading
    field :id, as: :id
    field :name, as: :text
    field :message, as: :text, only_on: :index, format_using: -> { value.truncate 30 }
    field :email, as: :text
    field :created_at, as: :date_time,
          readonly: true,
          sortable: true,
          name: "受信日時"
    field "ステータス", as: :heading
    field :status, as: :select,
          enum: ::Inquiry.statuses,
          sortable: true,
          display_with_value: true,
          hide_on: :index
    field :status, as: :text, only_on: :index, name: "対応状況" do
          case record.status
          when "unread"
            "未読"
          when "processing"
            "対応中"
          when "completed"
            "完了"
          else
            "不明"
          end
        end
    field "本文", as: :heading
    field :message, as: :textarea,
          readonly: true,
          rows: 10,
          hide_on: :index,
          format_using: -> {
            content_tag(:div, value,
              class: "w-full md:max-w-3xl break-words whitespace-pre-wrap min-h-[300px] p-4 rounded-md",
              style: "word-break: break-all;"
            )
          }
  end
end
