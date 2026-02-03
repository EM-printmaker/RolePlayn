class CharacterAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :city
  belongs_to :character
  belongs_to :expression

  def self.for_viewing(user, city)
    return nil if user.nil? || city.nil?

    includes(
      character: :expressions,
      expression: {
        image_attachment: {
          blob: { variant_records: { image_attachment: :blob } }
        }
      }
    ).find_by(user: user, city: city, assigned_date: Time.zone.today)
  end

  # その日の割り当てを確保または更新する
  def self.ensure_for_today!(user, city)
    assignment = find_or_initialize_by(user: user, city: city, assigned_date: Time.zone.today)
    return assignment unless assignment.new_record?

    last_assignment = where(user: user, city: city, assigned_date: ...Time.zone.today).
                      order(assigned_date: :desc).first

    character, expression = city.pick_random_character_with_expression(exclude: last_assignment&.character)

    if character && expression
      assignment.character = character
      assignment.expression = expression
      assignment.save!
    end
    assignment
  end

  # セッションデータからDBに保存
  def self.transfer_from_guest!(user, guest_assignments_hash)
    return if guest_assignments_hash.blank?

    guest_assignments_hash.each do |city_id, data|
      next if data["character_id"].blank? || data["expression_id"].blank?

      find_or_create_by!(
        user: user,
        city_id: city_id,
        assigned_date: data["assigned_date"]
      ) do |a|
        a.character_id = data["character_id"]
        a.expression_id = data["expression_id"]
      end
    end
  end
end
