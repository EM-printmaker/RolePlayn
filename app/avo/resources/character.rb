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
    field :name, as: :text
    field :description, as: :textarea
    field :city, as: :belongs_to
    field :city_id, as: :number, hide_on: :forms
    field :world, as: :record_link
    field :expressions, as: :has_many
    field :posts, as: :has_many
    field :character_assignments, as: :has_many, hide_on: :show
  end
end
