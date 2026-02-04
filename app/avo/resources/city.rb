class Avo::Resources::City < Avo::BaseResource
  self.includes = [ :world ]
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
    field :world_id, as: :number
    field :target_scope_type, as: :select, enum: ::City.target_scope_types
    field :target_world_id, as: :number
    field :slug, as: :text
    field :image, as: :file
    field :world, as: :belongs_to
    field :target_world, as: :belongs_to
    field :characters, as: :has_many
    field :posts, as: :has_many
    field :character_assignments, as: :has_many
  end
end
