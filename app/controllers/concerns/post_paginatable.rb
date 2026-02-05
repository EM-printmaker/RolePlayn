module PostPaginatable
  extend ActiveSupport::Concern

  private

  def paginate_posts(scope)
    @pagy, @posts = pagy(scope, limit: 10)
  end
end
