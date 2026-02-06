FactoryBot.define do
  factory :character do
    sequence(:name) { |n| "Name#{n}" }
    sequence(:description) { |n| "MyText #{n}" }
    city

    trait :with_expressions do
      after(:create) do |character|
        create(:expression, :with_image, character: character)
        create(:expression, :joy, :with_image, character: character)
      end
    end
  end
end
