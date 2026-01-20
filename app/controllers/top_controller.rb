class TopController < ApplicationController
  def index
    # これは表示確認用の仮の変数です。
    @worlds = World.includes(cities: { characters: { expressions: { image_attachment: { blob: :variant_records } } } }).all
  end
end
