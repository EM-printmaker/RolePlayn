world = World.find_or_create_by!(name: "ヴェルストリア")

city = world.cities.find_or_create_by!(name: "ルミノア")

characters_data = [
  { name: "村人", emotion_type: :joy },
  { name: "騎士", emotion_type: :fun }
]

characters_data.each_with_index do |data, i|
  character = city.characters.find_or_create_by!(name: data[:name]) do |c|
    c.description = "これはキャラクター#{data[:name]}のテスト文章です。"
  end

  (1..2).each do |lvl|
    filename = "character_test_image#{i + 1}-#{lvl}.png"
    image_path = Rails.root.join('spec', 'fixtures', filename)

    expression = character.expressions.find_or_create_by!(
      emotion_type: data[:emotion_type],
      level: lvl
    )

    expression.image.attach(
      io: image_path.open,
      filename: filename,
      content_type: 'image/png'
    )
  end
end
