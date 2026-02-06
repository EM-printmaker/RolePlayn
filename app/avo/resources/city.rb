class Avo::Resources::City < Avo::BaseResource
  self.includes = [ :world ]
  self.attachments = [ :image ]
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  self.stimulus_controllers = [ "conditional-fields" ]

  def fields
    field "基本情報", as: :heading
    field :id, as: :id
    field :name, as: :text, sortable: true, **admin_only_options
    field :slug, as: :text, **admin_only_options
    field :image, as: :file, is_image: true,
          accept: ImageValidatable::ALLOWED_IMAGE_TYPES.join(","),
          **admin_only_options
    field :created_at, as: :date_time,
          name: "作成日",
          readonly: true,
          sortable: true,
          format: "yyyy-MM-dd",
          hide_on: :forms
    field "所属", as: :heading
    field :world, as: :belongs_to,
          sortable: -> {
            query.joins(:world).order("worlds.name": direction)
          },
          **admin_only_options
    field :world_id, as: :number, only_on: :show
    field "ステータス", as: :heading
    field :target_scope_type, as: :select,
          enum: ::City.target_scope_types,
          html: {
            edit: {
              input: { data: { action: "change->conditional-fields#toggle" } }
            }
          },
          sortable: true,
          **admin_only_options
    field :target_world, as: :belongs_to,
          html: {
            edit: {
              wrapper: { data: { "conditional-fields-target": "targetField" } }
            }
          }
    field :target_world_id, as: :number, only_on: :show

    field :characters, as: :has_many
    field :posts, as: :has_many
  end
end
