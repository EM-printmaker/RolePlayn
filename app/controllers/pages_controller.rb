class PagesController < ApplicationController
  def login_announcement
    respond_to do |format|
      format.turbo_stream
    end
  end

  def terms; end

  def privacy; end
end
