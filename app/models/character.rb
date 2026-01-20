class Character < ApplicationRecord
  belongs_to :city
  has_many :expressions, dependent: :destroy
end
