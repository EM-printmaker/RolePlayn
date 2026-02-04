class Avo::Resources::Expression < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }
  self.default_view_type = :grid
  self.grid_view = {
    card: -> do
      {
        cover_url:
          if record.image.attached?
            main_app.cdn_image_url(record.image.variant(:display))
          end,
        title: "#{record.character.name} - #{record.emotion_type} (#{record.level})",
        body: "作成日: #{record.created_at.strftime('%Y/%m/%d')}"
      }
    end
  }
  def fields
    field :id, as: :id
    field :emotion_type, as: :select, enum: ::Expression.emotion_types
    field :level, as: :number
    field :character_id, as: :number
    field :image, as: :file, is_image: true
    field :character, as: :belongs_to
    field :posts, as: :has_many
    field :character_assignments, as: :has_many
  end
end
