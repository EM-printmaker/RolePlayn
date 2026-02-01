class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  enum :role, { general: 0, admin: 10 }

  validates :login_id,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[a-z0-9_]+\z/i },
            length: { in: 3..20 },
            allow_blank: true

  before_validation :downcase_login_id

  private

  def downcase_login_id
    self.login_id = login_id.downcase if login_id.present?
  end
end
