FactoryBot.define do
  factory :post do
    sequence(:content) { |n| "投稿テキスト #{n}" }
    sequence(:sender_session_token) { |n| "session_token_#{n}" }
    city { association :city }
    character { city.characters.first || association(:character, city: city) }
    expression do
      character.expressions.first || association(:expression, :with_image, character: character)
    end

    after(:build) do |post|
      if post.character.present?
        post.city = post.character.city
      end
    end
  end
end
