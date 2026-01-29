FactoryBot.define do
  factory :city do
    sequence(:name) { |n| "City #{n}" }
    sequence(:slug) { |n| "city-#{n}" }
    world
  end
end
