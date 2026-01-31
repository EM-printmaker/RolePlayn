RSpec.shared_examples "posts_load_more_behavior" do |path_proc|
  # ラムダなら instance_exec で実行、シンボルなら send。
  let(:base_path) { path_proc.respond_to?(:call) ? instance_exec(&path_proc) : send(path_proc) }

  let(:per_page) { 10 }
  let(:headers) { { "Turbo-Frame" => "pagination_frame" } }

  it "Turbo Stream形式で2ページ目のコンテンツを返すこと" do
    get base_path, params: { page: 2 }, as: :turbo_stream, headers: headers

    expect(response.media_type).to eq "text/vnd.turbo-stream.html"
    expect(response.body).to include('turbo-stream action="append" target="feed"')
    expect(response.body).to include('<li class="feed-item">')
  end

  it "2ページ目の読み込みで、重複しない投稿が返ってくること" do
    first_page_post = Post.order(created_at: :desc).first
    target_post = Post.order(created_at: :desc).offset(per_page).first

    get base_path, params: { page: 2 }, as: :turbo_stream, headers: headers

    expect(response.body).to include(target_post.content)
    expect(response.body).not_to include(first_page_post.content)
  end

  it "次のページがある場合、pagination-footer が更新されること" do
    get base_path, params: { page: 1 }, as: :turbo_stream, headers: headers

    expect(response.body).to include('turbo-stream action="replace" target="pagination-footer"')
    expect(response.body).to include('page=2')
  end

  it "最後のページ（2ページ目）で、終了メッセージが表示されること" do
    get base_path, params: { page: 2 }, as: :turbo_stream, headers: headers

    expect(response.body).to include("すべての投稿を読み込みました")
    expect(response.body).not_to include('loading="lazy"')
  end
end
