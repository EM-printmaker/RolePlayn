class User < ApplicationRecord
  RESERVED_LOGIN_IDS = %w[
    admin root system support help security moderator
    login logout signin signout register dashboard api
    guest everyone group public private
  ].freeze

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
    length: { in: 3..20 },
    exclusion: { in: RESERVED_LOGIN_IDS, message: :reserved_word },
    format: {
      with: /\A[a-z0-9](?:[a-z0-9_]*[a-z0-9])?\z/i, # 先頭と末尾は英数字のみ、中はアンダースコアも許可
      message: :invalid_format
    },
    if: -> { login_id.present? }

  validate :login_id_cannot_be_numeric
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

  def login_id_cannot_be_numeric
    if login_id.present? && login_id.match?(/\A\d+\z/)
      errors.add(:login_id, :numeric_only)
    end
  end
end
