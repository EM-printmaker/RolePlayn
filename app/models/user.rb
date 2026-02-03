class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable,
         authentication_keys: [ :login ]

  enum :role, { general: 0, admin: 10 }

  validates :login_id,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[a-z0-9_]+\z/i },
            length: { in: 3..20 },
            allow_blank: true

  before_validation :downcase_login_id

  attr_writer :login

  def login
    @login || self.login_id || self.email
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

  private

  def downcase_login_id
    self.login_id = login_id.downcase if login_id.present?
  end
end
