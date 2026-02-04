class Avo::Resources::Expression < Avo::BaseResource
  self.title = :display_name
  self.includes = [ character: { city: :world }, image_attachment: { blob: { variant_records: { image_attachment: :blob } } } ]
  self.attachments = [ :image ]
  self.search = {
    query: -> {
      emotion_value = ::Expression.emotion_types[q.downcase]
      query.ransack(
        character_name_cont: q,
        emotion_type_eq: emotion_value,
        id_eq: q,
        level_eq: q,
        m: "or"
      ).result(distinct: false)
    },
    item:  -> do
      {
        title: "#{record.character.name} - #{record.emotion_type}(#{record.level})"
      }
    end
  }
  self.default_view_type = :grid
  self.grid_view = {
    card: -> do
      {
        cover_url:
          if record.image.attached?
            main_app.cdn_image_url(record.image.variant(:display))
          end,
        title: "#{record.character.name} - #{record.emotion_type} (#{record.level})",
        body: "#{record.city.name}"
      }
    end
  }
  def fields
    field "基本情報", as: :heading
    field :id, as: :id
    field :image, as: :file, is_image: true, **admin_only_options
    field :character, as: :belongs_to,
          sortable: -> {
            query.joins(:character).order("characters.name #{direction}")
          },
          **admin_only_options
    field :character_id, as: :number, only_on: :show
    field :emotion_type, as: :select, enum: ::Expression.emotion_types,
          sortable: true,
          **admin_only_options
    field :level, as: :number, sortable: true, **admin_only_options
    field :created_at, as: :date_time,
          name: "作成日時",
          readonly: true,
          sortable: true,
          hide_on: :forms
    field "所属", as: :heading
    field :city, as: :record_link,
          sortable: -> {
            query.joins(character: :city).order("cities.name #{direction}")
          }
    field :world, as: :record_link,
          sortable: -> {
            query.joins(character: { city: :world }).order("worlds.name #{direction}")
          }

    field :posts, as: :has_many
  end
end
