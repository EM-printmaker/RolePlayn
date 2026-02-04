class Avo::Resources::CharacterAssignment < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :user_id, as: :number
    field :city_id, as: :number
    field :character_id, as: :number
    field :expression_id, as: :number
    field :assigned_date, as: :date
    field :user, as: :belongs_to
    field :city, as: :belongs_to
    field :character, as: :belongs_to
    field :expression, as: :belongs_to
  end
end
