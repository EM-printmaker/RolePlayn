module ImageValidatable
  extend ActiveSupport::Concern

    ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp].freeze
    MAX_IMAGE_SIZE = 1.megabyte.freeze

  class_methods do
    def validates_image(attribute_name)
      validate -> { validate_image_type(attribute_name) }
      validate -> { validate_image_size(attribute_name) }
    end
  end

  private

    def validate_image_type(attribute_name)
      attachment = public_send(attribute_name)
      return unless attachment.attached?

      unless attachment.content_type.in?(ALLOWED_IMAGE_TYPES)
        errors.add(attribute_name, :invalid_image_type)
      end
    end

    def validate_image_size(attribute_name)
      attachment = public_send(attribute_name)
      return unless attachment.attached?

      if attachment.blob.byte_size > MAX_IMAGE_SIZE
        count = (MAX_IMAGE_SIZE.to_f / 1.megabyte).round(1)
        errors.add(attribute_name, :file_too_big, count: count)
      end
    end
end
