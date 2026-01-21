require 'rails_helper'

RSpec.describe Expression, type: :model do
  subject(:expression) { create(:expression) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :character, Character
  end

  describe "image attachment" do
    let(:expression) { build(:expression, :with_image) }

    it '画像が正しくアタッチされていること' do
      expect(expression.image).to be_attached
    end

    it 'アタッチされたファイルの形式が正しいこと' do
      expect(expression.image.content_type).to eq('image/png')
    end
  end
end
