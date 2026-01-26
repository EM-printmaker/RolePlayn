module PostPaginatable
  extend ActiveSupport::Concern

  private

  def paginate_posts(scope)
    @pagy, @posts = pagy(
      scope.includes(:character, :expression).order(created_at: :desc),
      items: 10
    )

    respond_to do |format|
      format.html
      format.turbo_stream { render "shared/load_more" }
    end
  end
end
