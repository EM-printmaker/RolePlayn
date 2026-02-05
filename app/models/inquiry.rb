class Inquiry < ApplicationRecord
  belongs_to :user, optional: true
  has_many :related_inquiries,
    class_name: "Inquiry",
    primary_key: :user_id,
    foreign_key: :user_id,
    dependent: nil,
    inverse_of: false

  enum :status, {
    unread:     0, # 未読
    processing: 1, # 対応中
    completed:  2  # 完了
  }, default: :unread
  enum :category, {
    bug_report:       1, # 不具合
    feature_request:  2, # 要望
    account_issue:    3, # アカウント
    general:          10 # その他
  }, default: :bug_report

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { maximum: 5000 }

  def category_text
    I18n.t("enums.inquiry.category.#{category}") if category.present?
  end
end
