class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def read
    current_user.mark_notifications_as_read
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end
end
