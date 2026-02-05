class Avo::Resources::Inquiry < Avo::BaseResource
  self.includes = [ :registered_user ]
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def actions
    action Avo::Actions::MarkAsProcessing
    action Avo::Actions::PrepareReply
    action Avo::Actions::ReplyToInquiry
  end

  def fields
    field "基本情報", as: :heading
    field :id, as: :id
    field :category, as: :badge, name: "要件", sortable: true,
          options: {
            danger: :bug_report,
            warning: :feature_request,
            info: :account_issue,
            neutral: :general
          }
    field :name, as: :text, sortable: true, only_on: :index, format_using: -> { value.truncate 20 }
    field :name, as: :text
    field :message, as: :text, only_on: :index, format_using: -> { value.truncate 30 }
    field :email, as: :text do
            if record.registered_user.present?
              path = "#{root_path}/resources/users/#{record.registered_user.id}"
              link_to record.email, path, class: "text-blue-600"
            else
              record.email
            end
          end
    field :created_at, as: :date_time,
          readonly: true,
          sortable: true,
          name: "受信日時",
          format: "yyyy-MM-dd HH:mm"
    field "ステータス", as: :heading
    field :history_count, as: :text, name: "過去のやりとり", only_on: :show do
            count = record.same_email_inquiries.count - 1
            if count > 0
              "#{count}件の過去履歴あり"
            else
              "初めての問い合わせ"
            end
          end
    field :status, as: :select,
          enum: ::Inquiry.statuses,
          sortable: true,
          display_with_value: true,
          hide_on: :index
    field :status, as: :text, only_on: :index, sortable: true, name: "対応状況" do
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
    field "返信", as: :heading
    field :reply_subject, as: :text, name: "件名", hide_on: :index
    field :reply_body, as: :textarea, name: "Message",
          readonly: true,
          rows: 10,
          hide_on: :index,
          format_using: -> {
            content_tag(:div, value,
              class: "w-full md:max-w-3xl break-words whitespace-pre-wrap min-h-[300px] p-4 rounded-md",
              style: "word-break: break-all;"
            )
          }
    field :reply_sent_at, as: :date_time,
          name: "返信日時",
          readonly: true,
          only_on: [ :index, :show ],
          format: "yyyy-MM-dd HH:mm",
          sortable: true
    field :same_email_inquiries,
          use_resource: :inquiry,
          as: :has_many,
          name: "このユーザーからの問い合わせ",
          scope: -> { query.where.not(id: parent.id).order(created_at: :desc) }
  end
end
