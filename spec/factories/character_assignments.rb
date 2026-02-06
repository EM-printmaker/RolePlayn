FactoryBot.define do
  factory :character_assignment do
    user
    character
    city { character.city }
    expression do
      character.expressions.first || association(:expression, :with_image, character: character)
    end
    assigned_date { Time.zone.today }
  end
end
