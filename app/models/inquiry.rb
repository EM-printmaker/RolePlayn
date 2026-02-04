class Inquiry < ApplicationRecord
  # 未読: 0、対応中: 1、完了:  2
  enum :status, { unread: 0, processing: 1, completed: 2 }, default: :unread

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { maximum: 5000 }
end
