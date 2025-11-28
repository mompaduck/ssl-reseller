class NotificationLog < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :related_ticket, class_name: 'Ticket', optional: true
  belongs_to :related_order, class_name: 'Order', optional: true
  belongs_to :related_certificate, class_name: 'Certificate', optional: true

  # Enums
  enum :notification_type, {
    email: 0,
    sms: 1,
    slack: 2,
    push: 3,
    system: 4
  }, default: :email

  enum :status, {
    pending: 0,
    sent: 1,
    failed: 2
  }, default: :pending

  # Validations
  validates :recipient, presence: true
  validates :subject, presence: true
  validates :notification_type, presence: true
  validates :status, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) if type.present? }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_date_range, ->(start_date, end_date) {
    where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date.present? && end_date.present?
  }
  scope :search, ->(query) {
    where("recipient LIKE ? OR subject LIKE ? OR message LIKE ?", 
          "%#{query}%", "%#{query}%", "%#{query}%") if query.present?
  }

  # Badge color helpers
  def type_badge_color
    case notification_type
    when 'email'
      'bg-blue-100 text-blue-800'
    when 'sms'
      'bg-green-100 text-green-800'
    when 'slack'
      'bg-purple-100 text-purple-800'
    when 'push'
      'bg-orange-100 text-orange-800'
    when 'system'
      'bg-gray-100 text-gray-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def status_badge_color
    case status
    when 'sent'
      'bg-green-100 text-green-800'
    when 'failed'
      'bg-red-100 text-red-800'
    when 'pending'
      'bg-yellow-100 text-yellow-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
  
  # Class method to log notification
  def self.log_notification(params)
    create!(
      user_id: params[:user_id],
      recipient: params[:recipient],
      notification_type: params[:notification_type] || :email,
      subject: params[:subject],
      message: params[:message],
      message_preview: params[:message]&.truncate(200, omission: '...'),
      status: params[:status] || :sent,
      error_message: params[:error_message],
      sent_at: params[:sent_at] || Time.current,
      sender_id: params[:sender_id],
      ip_address: params[:ip_address],
      related_ticket_id: params[:related_ticket_id],
      related_order_id: params[:related_order_id],
      related_certificate_id: params[:related_certificate_id],
      metadata: params[:metadata]
    )
  rescue => e
    Rails.logger.error("Failed to log notification: #{e.message}")
    nil
  end
end
