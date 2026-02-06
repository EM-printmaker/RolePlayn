class CharacterAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :city
  belongs_to :character
  belongs_to :expression

  validates :assigned_date, presence: true
  validates :assigned_date, uniqueness: { scope: [ :user_id, :city_id ] }
  validate  :associations_consistency

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

  def self.exists_for_today?(user, city)
    return false if user.blank? || city.blank?

    exists?(user: user, city: city, assigned_date: Time.zone.today)
  end

  # その日の割り当てを確保または更新する
  def self.ensure_for_today!(user, city)
    assignment = find_or_initialize_by(user: user, city: city, assigned_date: Time.zone.today)
    return assignment unless assignment.new_record?

    last_assignment = where(user: user, city: city).where.not(id: assignment.id)
                      .order(assigned_date: :desc).first

    character, expression = city.pick_random_character_with_expression(exclude: last_assignment&.character)

    if character && expression
      assignment.character = character
      assignment.expression = expression
      assignment.save!
    else
      return nil
    end
    assignment
  end

  # 更新
  def shuffle!
    new_character, new_expression = city.pick_random_character_with_expression(exclude: self.character)

    if new_character && new_expression
      update!(character: new_character, expression: new_expression)
    end

    self
  end

  def switch_character!(new_character)
    target_expression = new_character.match_expression(self.expression)
    update!(character: new_character, expression: target_expression)
  end

  def change_expression!(new_expression)
    update!(expression: new_expression)
  end

  # セッションデータからDBに保存
  def self.transfer_from_guest!(user, guest_assignments_hash)
    return if guest_assignments_hash.blank?

    transaction do
      guest_assignments_hash.each do |city_id, data|
        next if data["character_id"].blank? || data["expression_id"].blank?

        assignment = find_or_initialize_by(
          user: user,
          city_id: city_id,
          assigned_date: data["assigned_date"].to_date
        )

        if assignment.new_record?
          assignment.character_id = data["character_id"]
          assignment.expression_id = data["expression_id"]
          assignment.save!
        end
      end
    end
  end

  private
    def associations_consistency
      if character.present? && city.present? && character.city_id != city_id
        errors.add(:character, "はこの都市に所属していません")
      end

      if expression.present? && character.present? && expression.character_id != character_id
        errors.add(:expression, "はこのキャラクターの表情ではありません")
      end
    end
end
