require 'rails_helper'

RSpec.describe Post, type: :model do
  subject(:post) { create(:post) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :city, City
    it_behaves_like "belongs_to_association", :character, Character
    it_behaves_like "belongs_to_association", :expression, Expression
  end
end
