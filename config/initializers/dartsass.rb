# TODO: BootstrapがDart Sassの新しい除算記法等に完全対応したらfalseに戻すことを検討。
# 現時点ではビルドログの視認性向上のため、依存関係の警告を無視。
Rails.application.config.dartsass.build_options << " --quiet-deps"

Rails.application.config.dartsass.builds = {
  "vendor.scss"      => "vendor.css",
  "application.scss" => "application.css"
}
