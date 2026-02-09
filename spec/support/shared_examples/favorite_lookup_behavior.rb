RSpec.shared_examples "favorite_lookup_behavior" do |target_path_block|
  let(:city) { create(:city) }
  let(:user) { create(:user) }
  let!(:post_record) { create(:post, user: user, city: city) }
  let(:target_path) { instance_exec(&target_path_block) }

  def html_for_post(post)
    doc = Nokogiri::HTML.parse(response.body)
    doc.at_css("#favorite_post_#{post.id}")&.to_s
  end

  describe "お気に入り状態の表示確認" do
    context "ログインしてお気に入り済みの時" do
      before do
        create(:post_favorite, user: user, post: post_record)
        sign_in user
        get target_path
      end

      it "対象の投稿のみが「削除(DELETE)」ボタンになっていること" do
        target_html = html_for_post(post_record)

        expect(target_html).to include('name="_method" value="delete"')
      end
    end

    context "未お気に入りの時" do
      before do
        other_post = create(:post)
        create(:post_favorite, user: user, post: other_post)
        sign_in user
        get target_path
      end

      it "対象の投稿には「削除(DELETE)」ボタンが含まれていないこと" do
        target_html = html_for_post(post_record)

        expect(target_html).not_to include('name="_method" value="delete"')
      end
    end
  end
end
