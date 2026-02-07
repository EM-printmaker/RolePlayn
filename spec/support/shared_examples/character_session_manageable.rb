RSpec.shared_examples "character_session_manageable" do |path_proc|
  let(:city) { create(:city) }
  let(:target_path) { path_proc.respond_to?(:call) ? instance_exec(&path_proc) : send(path_proc) }
  def current_guest_assignment(target_city)
    session.dig(:guest_assignments, target_city.id.to_s)
  end
  before do
    create(:character, :with_expressions, city: city)
  end

  describe "セッション情報のレスポンス" do
    it "セッションに保存されたキャラクターの名前がサイドバーに含まれていること" do
      get target_path
      assignment = current_guest_assignment(city)
      expect(assignment).to be_present
      current_character = Character.find(assignment["character_id"])
      expect(response.body).to have_selector(".side-nav", text: current_character.name)
    end

    it "セッションに保存されたキャラクターの画像がサイドバーに含まれていること" do
      get target_path
      assignment = current_guest_assignment(city)
      expect(assignment).to be_present
      current_expression = Expression.find(assignment["expression_id"])
      expected_filename = current_expression.image.filename.to_s
      expect(response.body).to have_selector(".side-nav img[src*='#{expected_filename}']")
    end

    context "ログインユーザーの場合" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "CharacterAssignment レコードが作成されること" do
        get target_path
        assignment = CharacterAssignment.find_by(user: user, city: city, assigned_date: Time.zone.today)
        expect(assignment).to be_present
        expect(assignment.character).to be_in(city.characters)
      end

      it "サイドバーにDBに保存されたキャラクター名が表示されること" do
        get target_path
        assignment = CharacterAssignment.find_by(user: user, city: city, assigned_date: Time.zone.today)
        expect(response.body).to have_selector(".side-nav", text: assignment.character.name)
      end
    end

    context "セッションにキャラクターが保存されていない場合" do
      before do
        Post.delete_all
        Expression.delete_all
        Character.delete_all
        session[:guest_assignments] = {}
        session[:viewing_city_id] = nil
      end

      it "「キャラクターを作成」ボタンがサイドバーに表示されること" do
        get target_path
        expect(response.body).to have_selector(".side-nav", text: "キャラクターを作成")
      end
    end
  end

  describe "セッションによるキャラクター管理" do
    before { create(:character, :with_expressions, city: city) }

    it "アクセスするたびに同じキャラクターが保持されること" do
      get target_path
      expect { get target_path }.not_to(
        change { current_guest_assignment(city)["character_id"] }
      )
    end

    it "日付が変わるとキャラクターが更新されること" do
      get target_path
      expect { travel_to(1.day.from_now) { get target_path } }.to(
        change { current_guest_assignment(city)["character_id"] }
      )
    end

    it "日付が変わると割り当て日が更新されること" do
      get target_path
      expect { travel_to(1.day.from_now) { get target_path } }.to(
        change { current_guest_assignment(city)["assigned_date"] }
      )
    end

    context "ログインユーザーの場合" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "同じ日に再アクセスしてもキャラクターが変わらないこと" do
        get target_path
        initial_assignment = CharacterAssignment.find_by(user: user, city: city)
        get target_path
        current_assignment = CharacterAssignment.find_by(user: user, city: city)
        expect(current_assignment.character_id).to eq(initial_assignment.character_id)
      end

      it "日付が変わると新しいレコードが作成され、キャラクターが更新されること" do
        get target_path
        initial_assignment = CharacterAssignment.find_by(user: user, city: city)
        initial_character_id = initial_assignment.character_id

        travel_to(1.day.from_now) do
          get target_path
          new_assignment = CharacterAssignment.find_by(user: user, city: city, assigned_date: Time.zone.today)

        expect(new_assignment).to be_present
        expect(new_assignment.id).not_to eq(initial_assignment.id)
        expect(new_assignment.character_id).not_to eq(initial_character_id)
        end
      end
    end
  end
end
