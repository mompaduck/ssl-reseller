class UserMailer < ApplicationMailer
  default from: ENV["SMTP_USERNAME"] || 'noreply@certgate.com'

  def confirmation_email(user)
    @user = user
    mail(
      to: @user.email,
      subject: "CertGate - 이메일 인증을 완료해주세요"
    )
  end

  def restore_account(user, token)
    @user = user
    @token = token
    mail(
      to: @user.email,
      subject: "CertGate - 계정 복구 안내"
    )
  end
end