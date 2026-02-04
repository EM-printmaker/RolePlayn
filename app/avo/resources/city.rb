class Avo::Resources::City < Avo::BaseResource
  self.includes = [ :world ]
  self.attachments = [ :image ]
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  self.find_record_method = -> {
    query.find_by slug: id
  }

  self.stimulus_controllers = [ "conditional-fields" ]

  def fields
    field :id, as: :id
    field :name, as: :text, sortable: true
    field :slug, as: :text
    field :image, as: :file
    field :world, as: :belongs_to, sortable: -> {
      query.joins(:world).order("worlds.name #{direction}")
    }
    field :world_id, as: :number, hide_on: :forms
    field :target_scope_type, as: :select,
          enum: ::City.target_scope_types,
          html: {
            edit: {
              input: { data: { action: "change->conditional-fields#toggle" } }
            }
          }, sortable: true
    field :target_world, as: :belongs_to,
          html: {
            edit: {
              wrapper: { data: { "conditional-fields-target": "targetField" } }
            }
          },
          sortable: -> {
            query.joins(:world).order("worlds.name #{direction}")
          }
    field :target_world_id, as: :number, hide_on: :forms
    field :created_at, as: :date_time,
      name: "作成日時",
      readonly: true,
      sortable: true,
      hide_on: :forms
    field :characters, as: :has_many
    field :posts, as: :has_many
    field :character_assignments, as: :has_many, hide_on: :show
  end
end
