class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field "基本情報", as: :heading
    field :id, as: :id
    field :login_id, as: :text, **admin_only_options
    field :email, as: :text, sortable: true, **admin_only_options
    field :role, as: :select, enum: ::User.roles, sortable: true, **admin_only_options
    field :confirmed_at, as: :date_time, sortable: true, **admin_only_options

    field "アカウント管理", as: :heading
    field :suspended_at, as: :date_time,
      name: "凍結日時",
      placeholder: "未凍結（空欄で解除）",
      hide_on: :index,
      **admin_only_options

    field :status, as: :text, only_on: :index, name: "状態" do
      if record.suspended_at.present?
        "🔴 凍結中"
      else
        "🟢 アクティブ"
      end
    end
    field :suspended_reason, as: :textarea, name: "凍結理由", **admin_only_options

    field "トラッキング", as: :heading
    field :sign_in_count, as: :number, hide_on: :index, **admin_only_options
    field :current_sign_in_at, as: :date_time, hide_on: :index, **admin_only_options
    field :last_sign_in_at, as: :date_time, hide_on: :index, **admin_only_options
    field :current_sign_in_ip, as: :text, hide_on: :index, **admin_only_options
    field :last_sign_in_ip, as: :text, hide_on: :index, **admin_only_options
    field :password, as: :password, hide_on: [ :index, :show, :edit ]
    field :password_confirmation, as: :password, hide_on: [ :index, :show, :edit ]
    # field :confirmation_token, as: :text, **admin_only_options
    # field :confirmation_sent_at, as: :date_time, **admin_only_options
    # field :unconfirmed_email, as: :text, **admin_only_options
  end
end
