FactoryBot.define do
  factory :world do
    sequence(:name) { |n| "World #{n}" }
    sequence(:slug) { |n| "world-#{n}" }
    is_global { false }

    trait :global do
      is_global { true }
      sequence(:slug) { |n| "global-world-#{n}" }
    end
  end
end
