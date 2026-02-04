FactoryBot.define do
  factory :inquiry do
    name { "MyString" }
    email { "MyString" }
    message { "MyText" }
    status { 1 }
  end
end
