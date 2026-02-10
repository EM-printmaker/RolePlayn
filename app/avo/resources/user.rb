class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }
  #
  def row_controls
    # 詳細・編集ボタンは全員に表示
    show_button
    edit_button

    # 削除ボタンだけ条件付きで表示（管理者のみ）
    if current_user.admin?
      delete_button
    end
  end

  # ▼ 詳細画面（Show）のボタン制御
  def show_controls
    # 戻る・編集ボタンは全員に表示
    back_button
    edit_button

    # 削除ボタンだけ条件付きで表示
    if current_user.admin?
      delete_button
    end

    # アクションボタン（パスワードリセットなど）がある場合もここで制御
    # actions_list if current_user.admin?
  end

  def fields
    field "基本情報", as: :heading
    field :id, as: :id
    field :login_id, as: :text, **admin_only_options
    field :email, as: :text, sortable: true, visible: -> { current_user.admin? }, **admin_only_options
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
      elsif record.access_locked?
        "🔒 ロック"
      else
        "🟢 アクティブ"
      end
    end
    field :suspended_reason, as: :textarea, name: "凍結理由", **admin_only_options
    field :failed_attempts, as: :number, readonly: true, only_on: :show, name: "ログイン失敗回数"
    field :locked_at, as: :date_time, readonly: true, only_on: :show, name: "自動ロック日時"

    field "トラッキング", as: :heading, only_on: :show
    field :sign_in_count, as: :number, only_on: :show, **admin_only_options
    field :current_sign_in_at, as: :date_time, only_on: :show, **admin_only_options
    field :last_sign_in_at, as: :date_time, only_on: :show, **admin_only_options
    field :current_sign_in_ip, as: :text, only_on: :show, visible: -> { current_user.admin? }, **admin_only_options
    field :last_sign_in_ip, as: :text, only_on: :show, visible: -> { current_user.admin? }, **admin_only_options
    field "パスワード", as: :heading, only_on: :new
    field :password, as: :password, only_on: :new
    field :password_confirmation, as: :password, only_on: :new
    # field :confirmation_token, as: :text, **admin_only_options
    # field :confirmation_sent_at, as: :date_time, **admin_only_options
    # field :unconfirmed_email, as: :text, **admin_only_options
    field :inquiries,
          as: :has_many,
          name: "お問い合わせ履歴",
          hide_search: true,
          scope: -> { query.order(created_at: :desc) }
    field :posts,
          as: :has_many
  end
end
