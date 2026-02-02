FactoryBot.define do
  factory :character_assignment do
    user
    city
    character
    expression
    assigned_date { Time.zone.today }
  end
end
