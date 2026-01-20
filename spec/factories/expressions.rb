FactoryBot.define do
  factory :expression do
    emotion_type { 1 }
    level { 1 }
    character

    trait :with_image do
      image { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/character_test_image1-1.png'), 'image/png') }
    end
  end
end
