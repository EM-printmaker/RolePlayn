FactoryBot.define do
  factory :post do
    sequence(:content) { |n| "MyText #{n}" }
    character
    expression
    city
  end
end
