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
    field :id, as: :id
    field :name, as: :text, sortable: true
    field :description, as: :textarea
    field :city, as: :belongs_to, sortable: -> {
      query.joins(:city).order("cities.name #{direction}")
    }
    field :city_id, as: :number, hide_on: :forms
    field :world, as: :record_link, sortable: -> {
      query.joins(city: :world).order("worlds.name #{direction}")
    }
    field :created_at, as: :date_time,
      name: "作成日時",
      readonly: true,
      sortable: true,
      hide_on: :forms
    field :expressions, as: :has_many
    field :posts, as: :has_many
    field :character_assignments, as: :has_many, hide_on: :show
  end
end
