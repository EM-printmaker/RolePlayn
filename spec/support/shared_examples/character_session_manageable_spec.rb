RSpec.shared_examples "character_session_manageable" do |path_proc|
  let(:city) { create(:city) }
  let(:target_path) { path_proc.respond_to?(:call) ? instance_exec(&path_proc) : send(path_proc) }
  before do
    create_list(:character, 2, :with_expressions, city: city)
    get target_path
  end

  describe "セッション情報のレスポンス" do
    it "セッションに保存されたキャラクターの名前がサイドバーに含まれていること" do
      current_character_id  = session[:active_character_id]
      current_character     = Character.find(current_character_id)
      expect(response.body).to have_selector(".side-nav", text: current_character.name)
    end

    it "セッションに保存されたキャラクターの画像がサイドバーに含まれていること" do
      current_expression_id = session[:active_expression_id]
      current_expression    = Expression.find(current_expression_id)
      expected_filename = current_expression.image.filename.to_s
      expect(response.body).to have_selector(".side-nav img[src*='#{expected_filename}']")
    end
  end

  describe "セッションによるキャラクター管理" do
    it "アクセスするたびに同じキャラクターが保持されること" do
      expect { get target_path }.not_to(change { session[:active_character_id] })
    end

    it "日付が変わるとキャラクターが更新されること" do
      expect {
        travel_to(1.day.from_now) { get target_path }
      }.to(change { session[:active_character_id] })
    end

    it "日付が変わると割り当て日が更新されること" do
      expect {
        travel_to(1.day.from_now) { get target_path }
      }.to(change { session[:assigned_date] })
    end
  end
end
