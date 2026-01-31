FactoryBot.define do
  factory :expression do
    emotion_type { Expression.emotion_types.keys.sample }
    level { |e| e.emotion_type.to_s == "normal" ? 1 : [ 1, 2 ].sample }

    character

    trait :with_image do
      image do |e|
        filename = "#{e.emotion_type}_test_image-#{e.level}.png"
        file_path = Rails.root.join("spec/fixtures/#{filename}")

        unless File.exist?(file_path)
          file_path = Rails.root.join("spec/fixtures/normal_test_image-1.png")
        end

        Rack::Test::UploadedFile.new(file_path, 'image/png')
      end
    end
  end
end
