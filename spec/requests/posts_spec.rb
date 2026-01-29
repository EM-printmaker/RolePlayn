require 'rails_helper'

RSpec.describe "Posts", type: :request do
  describe "POST /posts" do
    it "新しい投稿が作成され、レコード数が1増えること"
    it "正常なレスポンスが返ること"
    it "レスポンスが Turbo Stream 形式であること"
    it "フィードに新しい投稿が追加されること"
    it "入力フォームがリセットされること"
    it "sender_session_tokenが送信データに含まれていること"
    it "作成された投稿が、現在の街(City)に紐づいていること"
    it "作成された投稿が、現在のキャラクター(Character)に紐づいていること"
    it "作成された投稿が、現在の表情(Expression)に紐づいていること"

    context "投稿に失敗した場合" do
      it "レコードが作成されないこと"
      it "エラーメッセージが表示されること"
      it "422 Unprocessable Entity が返ること"
      it "入力済みの内容を保持したままであること"
    end

    context "短時間に連続して投稿した場合" do
      it "エラーになること"
    end
  end

  describe "DELETE /posts/:id" do
    it "レスポンスが Turbo Stream 形式であること"
    it "投稿が削除され、Post レコードが1減ること"
  end
end
