FactoryBot.define do
  factory :inquiry do
    sequence(:name) { |n| "ユーザー#{n}" }
    sequence(:email) { |n| "user_#{n}@example.com" }
    message { "システムの使い方について質問があります。" }
    status { :unread }

    trait :processing do
      status { :processing }
    end

    trait :closed do
      status { :closed }
    end
  end
end
