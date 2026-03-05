require 'rails_helper'

RSpec.describe "Expressions", type: :system do
it "表情変更モーダルが開く"
it "感情を追加すると該当する表情をプレビューできる"
it "表情一覧を表示できる"

  context "ログインユーザーの場合" do
    it "キャラクター一覧からキャラクターの選択ができる"
    it "表情をお気に入りに追加できる"
    it "表情お気に入り一覧が表示される"
  end
end
