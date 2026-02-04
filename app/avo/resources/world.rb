class Avo::Resources::World < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :name, as: :text, sortable: true, **admin_only_options
    field :is_global, as: :boolean, sortable: true, **admin_only_options
    field :slug, as: :text, sortable: true, **admin_only_options
    field :image, as: :file, **admin_only_options
    field :cities, as: :has_many
    field :observation_city_association, as: :has_one, sortable: -> {
      query.left_outer_joins(:observation_city_association).order("cities.name #{direction}")
    }
    field :created_at, as: :date_time,
      name: "作成日時",
      readonly: true,
      sortable: true,
      hide_on: :forms
  end
end
