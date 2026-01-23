class Post < ApplicationRecord
  belongs_to :city
  belongs_to :character
  belongs_to :expression

  validates :content, presence: true, length: { maximum: 300 }
end
