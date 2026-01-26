module ApplicationHelper
  def session_token(session_id)
    salt = Time.zone.now.strftime("%Y-%m-%d")
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, "#{session_id}#{salt}")
  end
end
