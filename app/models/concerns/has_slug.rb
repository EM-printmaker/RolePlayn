module HasSlug
  extend ActiveSupport::Concern

  RESERVED_SLUGS = %w[
    admin api assets blog cities contacts dashboard db
    edit graph images jobs load_more login logout
    members new notifications page pages password posts
    privacy profile public register search settings
    signin signout signup sitemap static stats terms
    test upload user users webhooks world worlds
  ].freeze

  included do
    validates :slug,
      presence: true,
      uniqueness: true,
      format: { with: /\A[a-z0-9\-]+\z/ },
      exclusion: {
        in: RESERVED_SLUGS,
        message: "「%{value}」はシステムで使用されているため利用できません"
      }
  end

  def to_param
    slug
  end
end
