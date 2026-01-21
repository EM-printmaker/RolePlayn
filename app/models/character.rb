class Character < ApplicationRecord
  belongs_to :city
  has_many :expressions, dependent: :destroy
  has_many :posts, dependent: :restrict_with_error

  include RandomSelectable
end
