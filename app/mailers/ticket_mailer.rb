class TicketMailer < ApplicationMailer
  default from: 'noreply@certgate.com'
  after_action :log_notification

  # 관리자가 답변했을 때 고객에게 알림
  def new_reply_notification(ticket, message)
    @ticket = ticket
    @message = message
    @customer_email = ticket.user ? ticket.user.email : ticket.guest_email
    @customer_name = ticket.user ? ticket.user.name : ticket.guest_name
    @sender = message.user # The admin/support who replied
    
    mail(
      to: @customer_email,
      subject: "[CertGate] 문의하신 티켓에 답변이 등록되었습니다 (#{ticket.ticket_number})"
    ) do |format|
      format.html
      format.text
    end
  end
  
  # 새 티켓이 생성되었을 때 관리자에게 알림
  def new_ticket_notification(ticket)
    @ticket = ticket
    
    # 관리자 이메일 목록 (환경변수 또는 설정에서 가져오기)
    admin_emails = User.where(role: [:admin, :super_admin, :support]).pluck(:email)
    
    return if admin_emails.empty?
    
    mail(
      to: admin_emails,
      subject: "[CertGate Admin] 새로운 고객 문의가 접수되었습니다 (#{ticket.ticket_number})"
    )
  end
  
  private
  
  def log_notification
    return unless message # Only log if email was actually sent
    
    # Determine user_id and sender_id based on action
    user_id = @ticket&.user_id
    sender_id = case action_name
    when 'new_reply_notification'
      @sender&.id || @message&.user_id
    when 'new_ticket_notification'
      nil # System notification
    end
    
    NotificationLog.log_notification(
      user_id: user_id,
      recipient: message.to&.first,
      notification_type: :email,
      subject: message.subject,
      message: extract_email_body,
      status: :sent,
      sent_at: Time.current,
      sender_id: sender_id,
      ip_address: nil, # Can be passed via params if needed
      related_ticket_id: @ticket&.id,
      related_order_id: @ticket&.order_id,
      related_certificate_id: @ticket&.certificate_id,
      metadata: {
        action: action_name,
        mailer: self.class.name
      }
    )
  rescue => e
    Rails.logger.error("Failed to log ticket notification: #{e.message}")
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
