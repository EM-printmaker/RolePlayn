class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :login_id, as: :text
    field :email, as: :text, sortable: true
    field :role, as: :select, enum: ::User.roles, sortable: true
    field :sign_in_count, as: :number, sortable: true
    field :current_sign_in_at, as: :date_time, sortable: true
    field :last_sign_in_at, as: :date_time, sortable: true
    field :current_sign_in_ip, as: :text
    field :last_sign_in_ip, as: :text
    field :confirmation_token, as: :text
    field :confirmed_at, as: :date_time
    field :confirmation_sent_at, as: :date_time
    field :unconfirmed_email, as: :text
    field :character_assignments, as: :has_many
  end
end
