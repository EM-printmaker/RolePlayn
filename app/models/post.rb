class Post < ApplicationRecord
  belongs_to :character
  belongs_to :expression
  belongs_to :city
end
