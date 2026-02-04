class Avo::Resources::Post < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :content, as: :textarea
    field :character_id, as: :number
    field :expression_id, as: :number
    field :city_id, as: :number
    field :sender_session_token, as: :text
    field :city, as: :belongs_to
    field :character, as: :belongs_to
    field :expression, as: :belongs_to
  end
end
