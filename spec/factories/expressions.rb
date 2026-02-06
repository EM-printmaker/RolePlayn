FactoryBot.define do
  factory :expression do
    emotion_type { :normal }
    level        { 1 }
    character

    after(:build) do |expression|
      attach_test_image(expression) if expression.image.blank?
    end

    trait :joy   do; emotion_type { :joy };   end
    trait :angry do; emotion_type { :angry }; end
    trait :sad   do; emotion_type { :sad };   end
    trait :fun   do; emotion_type { :fun };   end

    trait :level_2 do; level { 2 }; end

    trait :with_image do
      after(:build) do |expression|
        attach_test_image(expression)
      end
    end
  end
end

def attach_test_image(expression)
  filename = "#{expression.emotion_type}_test_image-#{expression.level}.png"
  file_path = Rails.root.join("spec/fixtures/#{filename}")
  file_path = Rails.root.join("spec/fixtures/normal_test_image-1.png") unless File.exist?(file_path)

  expression.image.attach(
    io: File.open(file_path),
    filename: File.basename(file_path),
    content_type: 'image/png'
  )
end
