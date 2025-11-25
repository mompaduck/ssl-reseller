class NotificationLog < ApplicationRecord
  # Enums
  enum :notification_type, {
    email: 0,
    sms: 1,
    slack: 2,
    push: 3
  }, default: :email

  enum :status, {
    pending: 0,
    sent: 1,
    failed: 2
  }, default: :pending

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
end
