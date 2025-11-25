class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SMTP_USERNAME', 'noreply@certgate.com')
  layout "mailer"
end
