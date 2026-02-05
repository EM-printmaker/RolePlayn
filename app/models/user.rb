class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable, :trackable, :lockable,
    authentication_keys: [ :login ]

  has_many :character_assignments, dependent: :destroy
  has_many :inquiries, dependent: :nullify

  enum :role, { general: 0, moderator: 5, admin: 10 }

  validates :login_id,
    uniqueness: { case_sensitive: false },
    format: { with: /\A[a-z0-9_]+\z/i },
    length: { in: 3..20 },
    if: -> { login_id.present? }

  before_validation :downcase_login_id

  attr_writer :login

  def login
    @login || self.login_id || self.email
  end

  def can_access_admin?
    admin? || moderator?
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where([ "lower(login_id) = :value OR lower(email) = :value", { value: login.downcase } ]).first
    else
      safe_conditions = conditions.to_h.select { |k, _v| column_names.include?(k.to_s) }
      where(safe_conditions).first
    end
  end

  # 凍結管理
  def active_for_authentication?
    super && suspended_at.nil?
  end

  def inactive_message
    if suspended_at.present?
      :suspended
    elsif access_locked?
      :locked
    else
      super
    end
  end

  private

  def downcase_login_id
    if login_id.present?
      self.login_id = login_id.downcase
    else
      self.login_id = nil
    end
  end
end
