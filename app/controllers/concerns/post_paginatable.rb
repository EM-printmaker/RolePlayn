module PostPaginatable
  extend ActiveSupport::Concern

  private

  def paginate_posts(scope)
    @pagy, @posts = pagy(
      :countish,
      scope.includes(:character, :expression)
      .order(created_at: :desc),
      limit: 10
    )
  end
end
