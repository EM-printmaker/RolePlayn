# This controller has been generated to enable Rails' resource routes.
# More information on https://docs.avohq.io/3.0/controllers.html
class Avo::CharactersController < Avo::ResourcesController
  before_action :block_avo_delete_for_guests

  private

  def block_avo_delete_for_guests
    if request.delete?
      unless current_user&.admin?
        flash[:alert] = t("avo.alerts.unauthorized")
        redirect_to root_path
      end
    end
  end
end
