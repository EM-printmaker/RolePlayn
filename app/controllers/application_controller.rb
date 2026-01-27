class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  include Pagy::Method

  before_action :set_all_worlds

  private

    def set_all_worlds
      @worlds = World.includes(:cities).all
    end
end
