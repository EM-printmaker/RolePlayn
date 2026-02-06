class UsersController < ApplicationController
  include CharacterSessionManageable
  include PostPaginatable

  before_action :prepare_viewing_context
  before_action :authenticate_user!

  def show
    @user = current_user
    @post = Post.new
    paginate_posts(@user.posts.latest.with_details)
  end

  private
    def prepare_viewing_context
      ensure_viewing_setup
      @city = viewing_city
    end
end
