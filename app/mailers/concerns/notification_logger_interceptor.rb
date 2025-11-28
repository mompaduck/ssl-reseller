class NotificationLoggerInterceptor
  def self.delivering_email(message)
    # Extract information from the email message
    recipient = message.to&.first
    subject = message.subject
    body = extract_body(message)
    
    # Try to extract context from message headers or params
    user_id = message['user_id']&.value
    sender_id = message['sender_id']&.value
    related_ticket_id = message['related_ticket_id']&.value
    related_order_id = message['related_order_id']&.value
    related_certificate_id = message['related_certificate_id']&.value
    ip_address = message['ip_address']&.value
    
    # Log the notification
    NotificationLog.log_notification(
      user_id: user_id,
      recipient: recipient,
      notification_type: :email,
      subject: subject,
      message: body,
      status: :sent,
      sent_at: Time.current,
      sender_id: sender_id,
      ip_address: ip_address,
      related_ticket_id: related_ticket_id,
      related_order_id: related_order_id,
      related_certificate_id: related_certificate_id
    )
  rescue => e
    Rails.logger.error("NotificationLoggerInterceptor error: #{e.message}")
  end
  
  def self.delivered_email(message)
    # Can be used for post-delivery actions if needed
  end
  
  private
  
  def self.extract_body(message)
    if message.multipart?
      # Try to get text/plain part first, fallback to html
      text_part = message.text_part&.body&.decoded
      html_part = message.html_part&.body&.decoded
      text_part || html_part || ''
    else
      message.body.decoded
    end
  rescue => e
    Rails.logger.error("Failed to extract email body: #{e.message}")
    ''
  end
end
