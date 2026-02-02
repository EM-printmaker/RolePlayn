module PostPaginatable
  extend ActiveSupport::Concern

  private

  def paginate_posts(scope)
    optimized_scope = scope.respond_to?(:with_details) ? scope.with_details : scope
    @pagy, @posts = pagy(
      :countish,
      optimized_scope,
      limit: 10
    )
  end
end
