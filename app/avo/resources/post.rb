class Avo::Resources::Post < Avo::BaseResource
  self.includes = [ :city, :character, :expression ]
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :content, as: :textarea
    field :content, as: :text, hide_on: :forms
    field :city, as: :belongs_to
    field :city_id, as: :number, hide_on: :forms
    field :character, as: :belongs_to
    field :character_id, as: :number, hide_on: :forms
    field :expression, as: :belongs_to
    field :expression_id, as: :number, hide_on: :forms
  end
end
