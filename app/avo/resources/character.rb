class Avo::Resources::Character < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :description, as: :textarea
    field :city, as: :belongs_to
    field :city_id, as: :number, hide_on: :forms
    field :expressions, as: :has_many
    field :posts, as: :has_many
    field :character_assignments, as: :has_many
  end
end
