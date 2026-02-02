class City < ApplicationRecord
  include RandomSelectable
  include HasSlug

  belongs_to :world
  belongs_to :target_world, class_name: "World", optional: true, inverse_of: :observation_city_association
  has_many :characters, dependent: :restrict_with_error
  has_many :posts, dependent: :restrict_with_error
  has_many :character_assignments, dependent: :destroy
  has_one_attached :image

  enum :target_scope_type, {
    self_only:      0,      # 自分自身の投稿のみ
    all_local:      1,      # すべてのLocal Worldの投稿
    specific_world: 2       # 特定のWorld配下の投稿
  }, default: :self_only

  validates :target_world_id, presence: true, if: :specific_world?

  scope :global, -> { joins(:world).merge(World.global) }
  scope :local, -> { joins(:world).merge(World.local) }
  scope :other_than, ->(city) { where.not(id: city.id) if city }

  delegate :global?, :local?, to: :world, allow_nil: true

  # 指定されたworldのpostを表示するCityを返す
  def self.observer_for(world)
    @_observers ||= {}
    @_observers[world.id] ||= find_by(target_scope_type: :specific_world, target_world_id: world.id)
  end

  # 全てのworldのpostを表示するCityを返す
  def self.global_observer
    @_global_observer ||= (find_by(target_scope_type: :all_local) || global.first)
  end

  # 既存のキャラを除外してランダムに取得、いなければ全体から取得
  def pick_random_character_with_expression(exclude: nil)
    character = characters.where.not(id: exclude&.id).pick_random || characters.pick_random
    return nil if character.nil?

    expression = character.expressions.pick_random
    [ character, expression ]
  end

  def feed_posts
    base_scope =
    case target_scope_type
    when "all_local"
      Post.from_local_worlds
    when "specific_world"
      Post.from_world(target_world_id)
    else
      Post.none
    end
    # 将来的にglobalでの投稿とbase_scopeの投稿を合わせて表示するため
    base_scope.or(Post.from_city(id)).order(created_at: :desc)
  end
end
