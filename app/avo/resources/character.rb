class Avo::Resources::Character < Avo::BaseResource
  self.includes = [
    { city: :world },
    { expressions: { image_attachment: { blob: :variant_records } } }
  ]
  # self.attachments = []
  self.search = {
    query: -> { query.ransack(id_eq: q, name_cont: q, city_name_cont: q, m: "or").result(distinct: false) },
    item:  -> do
      {
        title: "#{record.name}(#{record.city.name})"
      }
    end
  }

  def fields
    field "基本情報", as: :heading
    field :id, as: :id
    field :name, as: :text, sortable: true, **admin_only_options
    field :description, as: :textarea, **admin_only_options
    field :created_at, as: :date_time,
          name: "作成日時",
          readonly: true,
          sortable: true,
          hide_on: :forms
    field "所属", as: :heading
    field :city, as: :belongs_to,
          sortable: -> {
            query.joins(:city).order("cities.name #{direction}")
          },
          **admin_only_options
    field :city_id, as: :number, only_on: :show
    field :world, as: :record_link,
          sortable: -> {
            query.joins(city: :world).order("worlds.name #{direction}")
          }

    field :expressions, as: :has_many
    field :posts, as: :has_many
  end
end
