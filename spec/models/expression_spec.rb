require 'rails_helper'

RSpec.describe Expression, type: :model do
  describe "associations" do
    let(:expression) { create(:expression) }

    it "Characterに属していること" do
      expect(expression.character).to be_a(Character)
    end
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
