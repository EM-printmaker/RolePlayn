class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  include Pagy::Method
  include CharacterSessionManageable

  before_action :set_all_worlds
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    added_attrs = [ :login_id, :email, :password, :password_confirmation, :remember_me ]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: [ :login, :password ]
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  private

    def set_all_worlds
      @worlds = World.includes(:cities).all
    end

    def after_sign_in_path_for(resource)
      if session[:guest_assignments].present?
        CharacterAssignment.transfer_from_guest!(resource, session[:guest_assignments])
        session.delete(:guest_assignments)
      end

      if resource.sign_in_count == 1 && resource.login_id.blank?
        flash[:notice] = t("flash.sessions.welcome_and_setup_id")
        edit_user_registration_path
      else
        super
      end
    end
end
