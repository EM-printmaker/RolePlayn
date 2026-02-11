class Avo::Resources::Post < Avo::BaseResource
  self.includes = [ :city, :character, :expression ]
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field "基本情報", as: :heading
    field :id, as: :id
    field :content, as: :textarea, **admin_only_options
    field :content, as: :text, hide_on: [ :forms, :show ], format_using: -> { value.truncate 30 }
    field :created_at, as: :date_time,
          name: "作成日時",
          readonly: true,
          sortable: true,
          hide_on: :forms
    field "投稿者", as: :heading
    field :user, as: :belongs_to, hide_on: :forms,
          sortable: -> {
            query.joins(:user).order("user.email": direction)
          }
    field :city, as: :belongs_to,
          sortable: -> {
            query.joins(:city).order("city.name": direction)
          },
           **admin_only_options
    # field :city_id, as: :number, hide_on: [ :index, :forms ]
    field :character, as: :belongs_to,
          sortable: -> {
            query.joins(:character).order("character.name": direction)
          },
           **admin_only_options
    # field :character_id, as: :number, hide_on: [ :index, :forms ]
    field :expression, as: :belongs_to, **admin_only_options, hide_on: :index
    # field :expression_id, as: :number, hide_on: [ :index, :forms ]
  end
end
