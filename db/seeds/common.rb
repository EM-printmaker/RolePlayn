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
velstria.cities.find_or_create_by!(name: "ルミノア", slug: "luminoir")
velstria.cities.find_or_create_by!(name: "シミュラクラ", slug: "simulacra")

# プロトリス(protorys)
protorys.cities.find_or_create_by!(name: "ブランノード", slug: "blank-node")


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
