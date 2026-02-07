# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # rubocop:disable Lint/UselessMethodDefinition
  def create
    super
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    super
  end
  # rubocop:enable Lint/UselessMethodDefinition

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # GET /settings/password
  def edit_password
    self.resource = current_user
    render :edit_password
  end

  # PATCH /settings/password
  def update_password
    self.resource = current_user
    if resource.update_with_password(password_update_params)
      bypass_sign_in(resource)
      redirect_to edit_user_registration_path, notice: t("devise.registrations.password_updated")
    else
      clean_up_passwords resource
      render :edit_password, status: :unprocessable_entity
    end
  end

  protected

  # プロフィール更新（ID/Email）時の保存ロジック
  def update_resource(resource, params)
    if resource.login_id.blank?
      # 初回ログイン時（IDが空）：パスワードなしで更新を許可
      resource.update_without_password(params)
    else
      # 通常時：現在のパスワードを必須にする
      resource.update_with_password(params)
    end
  end

  def after_update_path_for(resource)
    if resource.just_set_login_id?
      flash[:notice] = t("devise.registrations.initial_setup_completed")
      root_path
    else
      edit_user_registration_path
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :login_id, :email ])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

    def added_attrs
      [ :login_id, :email, :password, :password_confirmation, :remember_me ]
    end

    def password_update_params
      params.require(:user).permit(:password, :password_confirmation, :current_password)
    end
end
