FactoryBot.define do
  factory :post do
    sequence(:content) { |n| "MyText #{n}" }
    city
    character { association :character, city: city }
    expression { association :expression, character: character }
    sequence(:sender_session_token) { |n| "session_token_#{n}" }

    transient do
      parent_world { nil }
      parent_city { nil }
      given_character { nil }
      given_expression { nil }
    end

    trait :with_full_data do
      city { parent_city || (parent_world ? association(:city, world: parent_world) : association(:city)) }
      character { given_character || association(:character, city: city) }
      expression { given_expression || association(:expression, :with_image, character: character) }
    end
  end
end
