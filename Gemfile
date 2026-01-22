source "https://rubygems.org"

gem "rails", "~> 7.2.3"
gem "bootsnap", require: false
gem "jbuilder"
gem "dartsass-rails"
gem "sprockets-rails"
gem "bootstrap", "~> 5.3.0"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "bcrypt", "~> 3.1.7"
gem "active_storage_validations"
gem "image_processing", "~> 1.2"
gem "aws-sdk-s3", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 7.1", ">= 7.1.1"
  gem "factory_bot_rails"
  gem "rubocop-rspec", require: false
  gem "rubocop-factory_bot", require: false
end

group :development do
  gem "web-console"
  gem "prism", "1.2.0"
  gem "ruby-lsp", require: false
end
