class Avo::Resources::Post < Avo::BaseResource
  self.includes = [ :city, :character, :expression ]
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :content, as: :textarea, **admin_only_options
    field :content, as: :text, hide_on: :forms
    field :city, as: :belongs_to, **admin_only_options
    field :city_id, as: :number, hide_on: [ :index, :forms ]
    field :character, as: :belongs_to, **admin_only_options
    field :character_id, as: :number, hide_on: [ :index, :forms ]
    field :expression, as: :belongs_to, **admin_only_options, hide_on: :index
    field :expression_id, as: :number, hide_on: [ :index, :forms ]
    field :created_at, as: :date_time,
      name: "作成日時",
      readonly: true,
      sortable: true,
      hide_on: :forms
  end
end
