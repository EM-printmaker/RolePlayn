require 'rails_helper'

RSpec.describe City, type: :model do
  subject(:city) { create(:city) }

  describe "associations" do
    it_behaves_like "belongs_to_association", :world, World
    it_behaves_like "has_many_association", :characters, :character, :city
    it_behaves_like "has_many_association", :posts, :post, :city
  end

  describe "deletion restrictions" do
    context "紐づくキャラクターが存在する場合" do
      before { create(:character, city: city) }

      it "削除しようとすると例外が発生して保護されること" do
        expect { city.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context "紐づく投稿が存在する場合" do
      before { create(:post, city: city) }

      it "削除しようとすると例外が発生して保護されること" do
        expect { city.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end

    context "紐づくレコードが存在しない場合" do
      let!(:city_without_associations) { create(:city) }

      it "正常に削除できること" do
        expect { city_without_associations.destroy! }.to change(described_class, :count).by(-1)
      end
    end
  end

  describe "#target_scope_type" do
    context "specific_worldの場合" do
      it "target_world_idが必須であること"
    end

    context "specific_world以外の場合" do
      it "target_world_idが空でも有効であること"
    end
  end

  describe "#slug(HasSlug)" do
    it "除外した文字列を使用すると保存に失敗すること"
  end

  describe ".global / .local" do
    it "globalスコープがグローバルなWorld(is_global:true)に所属する街のみを返すこと"
    it "localスコープがローカルなWorld(is_global:false)に所属する街のみを返すこと"
  end

  describe ".other_than" do
    it "引数で渡された都市を除外して返すこと"
    it "引数がnilの場合は、全件返すこと"
  end

  describe ".observer_for" do
    context "その世界を観測対象とする街(node)が存在する場合" do
      it "該当する街（specific_world）を返すこと"
    end

    context "その世界を観測対象とする都市が存在しない場合" do
      it "nil を返すこと"
    end
  end

  describe ".global_observer" do
    context "全ローカル世界を観測する都市（all_local）が存在する場合" do
      it "all_local設定の都市を返すこと"
    end

    context "all_localの都市がなく、Globalな都市が存在する場合" do
      it "Globalな都市の最初の1件を返すこと"
    end

    context "どちらも存在しない場合" do
      it "nil を返すこと"
    end
  end

  describe ".pick_random (RandomSelectable)" do
    it "登録されている街から 1 件が取得されること"
    it "レコードがない場合は nil を返すこと"
  end

  describe "#global?" do
    it "world.global? の結果を返すこと"
  end

  describe "#local?" do
    it "world.local? の結果を返すこと"
  end

  describe "#feed_posts" do
    context "設定が self_only (デフォルト) の場合" do
      it "自分の街の投稿のみが含まれること"
      it "他の街の投稿が含まれないこと"
    end

    context "設定が specific_world の場合" do
      it "指定されたターゲット世界の投稿が含まれること"
      it "自分自身の街の投稿も含まれること"
    end

    context "設定が all_local の場合" do
      it "全てのLocal Worldの投稿が含まれること"
    end

    it "作成日時の降順（新しい順）で返されること"
  end
end
