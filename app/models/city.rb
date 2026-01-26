class City < ApplicationRecord
  belongs_to :world
  belongs_to :target_world, class_name: "World", optional: true
  has_many :characters, dependent: :restrict_with_error
  has_many :posts, dependent: :restrict_with_error
  has_one_attached :image

  include RandomSelectable

  scope :global, -> { joins(:world).merge(World.global) }
  scope :local, -> { joins(:world).merge(World.local) }

  enum :target_scope_type, {
    self_only: 0,      # 自分自身の投稿のみ
    all_local: 1,      # すべてのLocal Worldの投稿
    specific_world: 2  # 特定のWorld配下の投稿
  }, default: :self_only

  validates :target_world_id, presence: true, if: :specific_world?

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
