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
      it "target_world_idが必須であること" do
        city.target_scope_type = :specific_world
        city.target_world_id = nil
        expect(city).not_to be_valid
      end
    end

    context "specific_world以外の場合" do
      it "target_world_idが空でも有効であること" do
        city.target_scope_type = :self_only
        city.target_world_id = nil
        expect(city).to be_valid
      end
    end
  end

  describe "#slug(HasSlug)" do
    it "除外した文字列を使用すると保存に失敗すること" do
      invalid_city = build(:city, slug: "new")
      expect(invalid_city).not_to be_valid
    end
  end

  describe ".global / .local" do
    let(:global_world) { create(:world, is_global: true) }
    let(:local_world) { create(:world, is_global: false) }
    let!(:global_city) { create(:city, world: global_world) }
    let!(:local_city) { create(:city, world: local_world) }

    it "globalスコープがグローバルなWorld(is_global:true)に所属する街のみを返すこと" do
      expect(described_class.global).to include(global_city)
      expect(described_class.global).not_to include(local_city)
    end

    it "localスコープがローカルなWorld(is_global:false)に所属する街のみを返すこと" do
      expect(described_class.local).to include(local_city)
      expect(described_class.local).not_to include(global_city)
    end
  end

  describe ".other_than" do
    let!(:target_city) { create(:city) }

    it "引数で渡された都市を除外して返すこと" do
      expect(described_class.other_than(target_city)).not_to include(target_city)
    end

    it "引数がnilの場合は、全件返すこと" do
      expect(described_class.other_than(nil).count).to eq described_class.count
    end
  end

  describe ".observer_for(world)" do
    let!(:world) { create(:world) }
    let!(:target_world) { create(:world) }
    let!(:observer_city) { create(:city, :observer, target_world_id: target_world.id) }

    context "その世界を観測対象とする街(node)が存在する場合" do
      it "該当する街（specific_world）を返すこと" do
        expect(described_class.observer_for(target_world)).to eq observer_city
      end
    end

    context "その世界を観測対象とする都市が存在しない場合" do
      it "nil を返すこと" do
        expect(described_class.observer_for(world)).to be_nil
      end
    end
  end

  describe ".global_observer" do
    it "優先してall_local設定の都市を返すこと" do
      all_local_city = create(:city, :all_local)
      expect(described_class.global_observer).to eq all_local_city
    end

    it "all_localがない場合、Globalな都市の最初の1件を返すこと" do
      described_class.global.delete_all
      target_city = create(:city, :global)
      _other_city = create(:city, :global)
      expect(described_class.global_observer).to eq target_city
    end
  end

  describe ".pick_random (RandomSelectable)" do
    before { create_list(:city, 2) }

    it "登録されている街から 1 件が取得されること" do
      result = described_class.pick_random
      expect(result).to be_a(described_class)
      expect(result).not_to be_nil
    end
  end

  describe "#pick_random_character_with_expression" do
    let(:city) { create(:city) }
    let!(:character) { create(:character, city: city) }
    let!(:new_character) { create(:character, city: city) }

    it "excludeで指定したキャラクターは選ばれないこと" do
      10.times do
        result_char, _ = city.pick_random_character_with_expression(exclude: character)
        expect(result_char).to eq new_character
      end
    end
  end

  describe "#global?" do
    let(:world) { city.world }

    it "world.global? の結果を返すこと" do
      allow(world).to receive(:global?).and_return(true)
      expect(city.global?).to be true
    end
  end

  describe "#local?" do
    let(:world) { city.world }

    it "world.local? の結果を返すこと" do
      allow(world).to receive(:local?).and_return(true)
      expect(city.local?).to be true
    end
  end

  describe "#feed_posts" do
    let!(:my_post) { create(:post, city: city) }

    context "設定が self_only (デフォルト) の場合" do
      it "自分の街の投稿のみが含まれること" do
        other_post = create(:post)
        expect(city.feed_posts).to include(my_post)
        expect(city.feed_posts).not_to include(other_post)
      end
    end

    context "設定が specific_world の場合" do
      let(:observer_city) { create(:city, :observer, target_world_id: city.world.id) }

      it "指定されたターゲット世界の投稿と自分自身の投稿が含まれること" do
        posts = observer_city.feed_posts
        expect(posts).to include(my_post)
        expect(posts).to include(create(:post, city: observer_city))
      end
    end

    context "設定が all_local の場合" do
      let(:all_local_city) { create(:city, :all_local) }

      it "全てのLocal Worldの投稿が含まれること" do
        other_post = create(:post)
        expect(all_local_city.feed_posts).to include(my_post, other_post)
      end
    end

    it "作成日時の降順（新しい順）で返されること" do
      create(:post, city: city, created_at: 1.day.ago)
      new_post = create(:post, city: city, created_at: Time.current)
      expect(city.feed_posts.first).to eq new_post
    end
  end
end
