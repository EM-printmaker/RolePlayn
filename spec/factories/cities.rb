FactoryBot.define do
  factory :city do
    sequence(:name) { |n| "City #{n}" }
    sequence(:slug) { |n| "city-#{n}" }
    world
    target_scope_type { :self_only }

    trait :global do
      world { association :world, :global }
    end

    trait :specific_world do
      target_scope_type { :specific_world }
    end

    trait :all_local do
      target_scope_type { :all_local }
    end

    trait :observer do
      global
      specific_world
    end
  end
end
