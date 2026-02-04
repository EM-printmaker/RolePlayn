module HasSlug
  extend ActiveSupport::Concern

  RESERVED_SLUGS = %w[
    admin api assets blog cities contacts dashboard db
    edit graph images jobs load_more login logout
    members new notifications page pages password posts
    privacy profile public register search settings
    signin signout signup sitemap static stats terms
    test upload user users webhooks world worlds
    top re_rolls shuffles character_selections rails up
    preview expressions
  ].freeze

  included do
    before_validation :normalize_slug
    validates :slug,
      presence: true,
      uniqueness: true,
      format: { with: /\A[a-z0-9\-]+\z/ },
      exclusion: {
        in: RESERVED_SLUGS
      }
  end

  # def to_param
  #  slug
  # end

  private

    def normalize_slug
      return if slug.blank?
      self.slug = slug.to_s.downcase.strip.gsub(/[^a-z0-9\-]+/, "-").gsub(/^-+|-+$/, "")
    end
end
