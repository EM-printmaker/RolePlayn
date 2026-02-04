class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :login_id, as: :text, **admin_only_options
    field :email, as: :text, sortable: true, **admin_only_options
    field :role, as: :select, enum: ::User.roles, sortable: true, **admin_only_options
    field :sign_in_count, as: :number, sortable: true, **admin_only_options
    field :current_sign_in_at, as: :date_time, sortable: true, **admin_only_options
    field :last_sign_in_at, as: :date_time, sortable: true, **admin_only_options
    field :current_sign_in_ip, as: :text, **admin_only_options
    field :last_sign_in_ip, as: :text, **admin_only_options
    field :confirmation_token, as: :text, **admin_only_options
    field :confirmed_at, as: :date_time, **admin_only_options
    field :confirmation_sent_at, as: :date_time, **admin_only_options
    field :unconfirmed_email, as: :text, **admin_only_options
    field :character_assignments, as: :has_many
  end
end
