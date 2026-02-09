class ApplicationMailer < ActionMailer::Base
  default from: -> { "RolePlayn サポート <#{ENV['MAIL_FROM_ADDRESS']}>" }
  layout "mailer"
end
