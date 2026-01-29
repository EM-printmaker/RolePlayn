FactoryBot.define do
  factory :world do
    sequence(:name) { |n| "World #{n}" }
    sequence(:slug) { |n| "world-#{n}" }
    is_global { false }
  end
end
