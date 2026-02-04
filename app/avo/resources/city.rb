class Avo::Resources::City < Avo::BaseResource
  self.includes = [ :world ]
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  self.find_record_method = -> {
    query.find_by slug: id
  }

  self.stimulus_controllers = [ "conditional-fields" ]

  def fields
    field :id, as: :id
    field :name, as: :text
    field :slug, as: :text
    field :image, as: :file
    field :world, as: :belongs_to
    field :world_id, as: :number, hide_on: :forms
    field :target_scope_type, as: :select,
          enum: ::City.target_scope_types,
          html: {
            edit: {
              input: { data: { action: "change->conditional-fields#toggle" } }
            }
          }
    field :target_world, as: :belongs_to,
          html: {
            edit: {
              wrapper: { data: { "conditional-fields-target": "targetField" } }
            }
          }
    field :target_world_id, as: :number, hide_on: :forms
    field :characters, as: :has_many
    field :posts, as: :has_many
    field :character_assignments, as: :has_many
  end
end
