# 全環境共通
load Rails.root.join("db/seeds/common.rb")

# 環境別
if Rails.env.development?
  load Rails.root.join("db/seeds/development.rb")
end
