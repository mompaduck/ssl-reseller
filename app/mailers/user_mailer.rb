class UserMailer < ApplicationMailer
  default from: ENV["SMTP_USERNAME"] || 'noreply@certgate.com'
  after_action :log_notification

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
  
  private
  
  def log_notification
    return unless message
    
    NotificationLog.log_notification(
      user_id: @user&.id,
      recipient: message.to&.first,
      notification_type: :email,
      subject: message.subject,
      message: extract_email_body,
      status: :sent,
      sent_at: Time.current,
      sender_id: nil, # System-generated
      ip_address: nil,
      metadata: {
        action: action_name,
        mailer: self.class.name
      }
    )
  rescue => e
    Rails.logger.error("Failed to log UserMailer notification: #{e.message}")
  end
  
  def extract_email_body
    if message.multipart?
      message.text_part&.body&.decoded || message.html_part&.body&.decoded || ''
    else
      message.body.decoded
    end
  rescue
    ''
  end
end