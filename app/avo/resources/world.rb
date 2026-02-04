class Avo::Resources::World < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  self.find_record_method = -> {
    query.find_by slug: id
  }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :is_global, as: :boolean
    field :slug, as: :text
    field :image, as: :file
    field :cities, as: :has_many
    field :observation_city_association, as: :has_one
  end
end
