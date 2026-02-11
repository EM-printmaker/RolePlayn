# global
global_world = World.find_or_create_by!(name: "アセラ・ポリス", is_global: true, slug: "acerapolis")

node_00 = global_world.cities.find_or_create_by!(name: "境界観測点 [Node.00]", slug: "node00")
node_01 = global_world.cities.find_or_create_by!(name: "境界観測点 [Node.01]", slug: "node01")
node_02 = global_world.cities.find_or_create_by!(name: "境界観測点 [Node.02]", slug: "node02")

# local World
velstria = World.find_or_create_by!(name: "ヴェルストリア", slug: "velstria")

protorys = World.find_or_create_by!(name: "プロトリス", slug: "protorys")

# City
# ヴェルストリア(velstria)
luminoir      = velstria.cities.find_or_create_by!(name: "ルミノア", slug: "luminoir")
velstria_city = velstria.cities.find_or_create_by!(name: "シミュラクラ", slug: "simulacra")

# プロトリス(protorys)
blank_node = protorys.cities.find_or_create_by!(name: "ブランノード", slug: "blank-node")


# feed_posts(postの参照先)
# 全Localを参照
node_00.all_local!

# ヴェルストリア(velstria)のみを参照
node_01.update!(
  target_scope_type: :specific_world,
  target_world_id: velstria.id
)

# プロトリス(protorys)のみを参照
node_02.update!(
  target_scope_type: :specific_world,
  target_world_id: protorys.id
)

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
  (1..2).each do |num|
    content = "[#{character.city.name}]テスト投稿その#{num}：#{data[:name]}の文章です。"
    character.posts.find_or_create_by!(content: content) do |p|
      p.city = character.city
      p.expression = character.expressions.pick_random
      p.sender_session_token = SecureRandom.hex(16)
    end
  end
end

# users
admin_email = ENV.fetch("ADMIN_USER_EMAIL", "admin@example.com")
users_data = [
  { login_id: "admin_user",  email: admin_email,  role: :admin },
  { login_id: "guest_moderator", email: "guest_moderator@example.com", role: :moderator },
  { login_id: "guest_user", email: "guest@example.com", role: :general }
]
users_data.each do |data|
  user = User.find_or_initialize_by(login_id: data[:login_id])
  user.email = data[:email]
  user.role = data[:role]
  user.skip_confirmation!
  user.skip_reconfirmation! if user.respond_to?(:skip_reconfirmation!)
  user.confirmed_at = Time.current

  if user.new_record?
    if data[:role] == :admin
      password = Rails.application.credentials.seed_user_password || ENV.fetch("SEED_USER_PASSWORD", "password")
    else
      password = SecureRandom.urlsafe_base64(12)
    end

    user.password = password
    user.password_confirmation = password
  end

  user.save!
end
