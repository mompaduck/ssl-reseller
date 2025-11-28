class PasswordsMailer < ApplicationMailer
  after_action :log_notification
  
  def reset(user)
    @user = user
    mail subject: "CertGate - 비밀번호 재설정", to: user.email
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
    Rails.logger.error("Failed to log PasswordsMailer notification: #{e.message}")
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
