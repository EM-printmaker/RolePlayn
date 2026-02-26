luminoir = City.find_by!(slug: "luminoir")
velstria_city = City.find_by!(slug: "simulacra")
blank_node = City.find_by!(slug: "blank-node")


# character
characters_data = [
  { name: "村人", city: luminoir,      emotion_types: [ :joy, :angry, :sad,   :fun, :normal ] },
  { name: "騎士", city: luminoir,      emotion_types: [ :joy, :angry, :sad,   :fun, :normal ] },
  { name: "衛兵", city: velstria_city, emotion_types: [ :joy, :angry, :sad,   :fun, :normal ] },
  { name: "商人", city: velstria_city, emotion_types: [ :joy, :angry, :sad,   :fun, :normal ] },
  { name: "町人", city: blank_node,      emotion_types: [ :joy, :angry, :sad,   :fun, :normal ] },
  { name: "旅人", city: blank_node,      emotion_types: [ :joy, :angry, :sad,   :fun, :normal ] }
]

characters_data.each do |data|
  character = Character.find_or_create_by!(name: data[:name], city_id: data[:city].id) do |c|
    c.city = data[:city]
    c.description = "これはキャラクター#{data[:name]}のテスト文章です。"
  end

  # expression
  data[:emotion_types].each do |emo|
    levels = (emo == :normal) ? [ 1 ] : [ 1, 2 ]
    levels.each do |lvl|
      filename = "#{emo}_test_image-#{lvl}.png"
      image_path = Rails.root.join('spec', 'fixtures', filename)

      unless File.exist?(image_path)
        Rails.logger.warn "Warning: #{image_path} の画像が見つかりません"
        next
      end

      expression = character.expressions.find_or_initialize_by(
        emotion_type: emo,
        level: lvl
      )

      unless expression.image.attached?
        expression.image.attach(
          io: image_path.open,
          filename: "#{character.name}#{filename}",
          content_type: 'image/png'
        )
        expression.save!
      end
    end
  end

  # post
  (1..6).each do |num|
    content = "[#{character.city.name}]テスト投稿その#{num}：#{data[:name]}の文章です。"
    character.posts.find_or_create_by!(content: content) do |p|
      p.city = character.city
      p.expression = character.expressions.pick_random
      p.sender_session_token = SecureRandom.hex(16)
    end
  end
end
