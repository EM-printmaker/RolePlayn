class CharacterAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :city
  belongs_to :character
  belongs_to :expression
end
