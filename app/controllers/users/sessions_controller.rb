# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [ :create ]

  # 一般ゲストログイン
  def new_guest
    user = User.find_or_create_by!(email: "guest@example.com") do |u|
      u.password = SecureRandom.urlsafe_base64
      u.role = :general
      u.login_id = "guest_general"
    end

    sign_in user
    redirect_to root_path, notice: t("devise.sessions.guest_signed_in")
  end

  # モデレーターゲストログイン
  def new_guest_moderator
    user = User.find_or_create_by!(email: "guest_moderator@example.com") do |u|
      u.password = SecureRandom.urlsafe_base64
      u.role = :moderator
      u.login_id = "guest_moderator"
    end

    sign_in user
    redirect_to root_path, notice: t("devise.sessions.moderator_signed_in")
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # rubocop:disable Lint/UselessMethodDefinition
  def create
    super
  end
  # rubocop:enable Lint/UselessMethodDefinition

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [ :login, :password ])
  end
end
