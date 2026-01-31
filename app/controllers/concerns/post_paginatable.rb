module PostPaginatable
  extend ActiveSupport::Concern

  private

  def paginate_posts(scope)
    @pagy, @posts = pagy(
      :countish,
      scope.includes(:character, :expression),
      limit: 10
    )
  end
end
