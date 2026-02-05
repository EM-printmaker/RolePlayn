# global
global_world = World.find_or_create_by!(name: "アセラ・ポリス", is_global: true, slug: "acerapolis")

node_00 = global_world.cities.find_or_create_by!(name: "境界観測点 [Node.00]", slug: "node00")
node_01 = global_world.cities.find_or_create_by!(name: "境界観測点 [Node.01]", slug: "node01")
node_02 = global_world.cities.find_or_create_by!(name: "境界観測点 [Node.02]", slug: "node02")

# local World
velstria = World.find_or_create_by!(name: "ヴェルストリア", slug: "velstria")

test_world = World.find_or_create_by!(name: "テストワールド", slug: "test-world")

# City
# ヴェルストリア(velstria)
luminoir      = velstria.cities.find_or_create_by!(name: "ルミノア", slug: "luminoir")
velstria_city = velstria.cities.find_or_create_by!(name: "ヴェルストリア所属City", slug: "velstria-city")

# テストワールド(test_world)
test_city = test_world.cities.find_or_create_by!(name: "テストワールド所属City", slug: "test-city")


# feed_posts(postの参照先)
# 全Localを参照
node_00.all_local!

# ヴェルストリア(velstria)のみを参照
node_01.update!(
  target_scope_type: :specific_world,
  target_world_id: velstria.id
)

# テストワールド(test_world)のみを参照
node_02.update!(
  target_scope_type: :specific_world,
  target_world_id: test_world.id
)

# character
characters_data = [
  { name: "村人", city: luminoir,      emotion_types: [ :joy, :angry, :sad,   :fun, :normal ] },
  { name: "騎士", city: luminoir,      emotion_types: [ :fun, :sad,   :normal ] },
  { name: "衛兵", city: velstria_city, emotion_types: [ :joy, :angry, :sad,   :fun, :normal ] },
  { name: "商人", city: velstria_city, emotion_types: [ :joy, :fun,   :normal ] },
  { name: "町人", city: test_city,     emotion_types: [ :joy, :angry, :sad,   :fun, :normal ] },
  { name: "旅人", city: test_city,     emotion_types: [ :sad, :fun,   :normal ] }
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
  (1..10).each do |num|
    content = "[#{character.city.name}]テスト投稿その#{num}：#{data[:name]}の文章です。"
    character.posts.find_or_create_by!(content: content) do |p|
      p.city = character.city
      p.expression = character.expressions.pick_random
      p.sender_session_token = SecureRandom.hex(16)
    end
  end
end

# users
users_data = [
{ login_id: "test",  email: "test@example.com",  role: :admin },
  { login_id: "test2", email: "test2@example.com", role: :moderator },
  { login_id: "test3", email: "test3@example.com", role: :general }
]
users_data.each do |data|
  User.find_or_create_by!(login_id: data[:login_id]) do |u|
    u.email = data[:email]
    u.password = "password"
    u.password_confirmation = "password"
    u.role = data[:role]
    u.skip_confirmation! if u.respond_to?(:skip_confirmation!)
  end
end
