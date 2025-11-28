# Notification Logging Implementation Guide

## Overview
This guide explains how to integrate notification logging into mailers for comprehensive tracking of all email communications.

## Quick Start

### For New Mailers

Add the `after_action :log_notification` callback to your mailer:

```ruby
class YourMailer < ApplicationMailer
  after_action :log_notification
  
  def your_email_method(params)
    @user = params[:user]
    @resource = params[:resource]
    
    mail(to: @user.email, subject: "Your Subject")
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
      sender_id: current_admin&.id, # If applicable
      related_order_id: @resource&.id, # Adjust based on your resource
      metadata: {
        action: action_name,
        mailer: self.class.name
      }
    )
  rescue => e
    Rails.logger.error("Failed to log notification: #{e.message}")
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
```

## Available Fields

- `user_id`: Recipient user ID (if registered user)
- `recipient`: Email address
- `notification_type`: `:email`, `:sms`, `:system`, etc.
- `subject`: Email subject
- `message`: Full email body
- `message_preview`: Auto-generated (first 200 chars)
- `status`: `:sent`, `:failed`, `:pending`
- `error_message`: Error details if failed
- `sent_at`: Timestamp
- `sender_id`: Admin/staff who triggered the email
- `ip_address`: Request IP (if available)
- `related_ticket_id`: Associated ticket
- `related_order_id`: Associated order
- `related_certificate_id`: Associated certificate
- `metadata`: Additional JSON data

## Examples

### Ticket Reply Notification
```ruby
NotificationLog.log_notification(
  user_id: ticket.user_id,
  recipient: customer_email,
  subject: "Ticket Reply",
  message: email_body,
  sender_id: admin.id,
  related_ticket_id: ticket.id
)
```

### Order Confirmation
```ruby
NotificationLog.log_notification(
  user_id: order.user_id,
  recipient: order.user.email,
  subject: "Order Confirmed",
  message: email_body,
  related_order_id: order.id
)
```

### DCV Failure Alert
```ruby
NotificationLog.log_notification(
  user_id: certificate.user_id,
  recipient: certificate.user.email,
  subject: "DCV Validation Failed",
  message: email_body,
  related_certificate_id: certificate.id,
  related_order_id: certificate.order_id
)
```
