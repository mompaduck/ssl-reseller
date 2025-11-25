class CertificateLog < ApplicationRecord
  belongs_to :certificate
  belongs_to :user, optional: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) if action.present? }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_date_range, ->(start_date, end_date) {
    where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date.present? && end_date.present?
  }
  scope :search, ->(query) {
    if query.present?
      joins(:certificate).joins("LEFT JOIN users ON users.id = certificate_logs.user_id")
        .where("certificate_logs.message LIKE ? OR certificates.common_name LIKE ? OR users.name LIKE ?", 
               "%#{query}%", "%#{query}%", "%#{query}%")
    end
  }

  # Action types
  ACTION_TYPES = %w[
    issued
    renewed
    cancelled
    revoked
    dcv_sent
    dcv_completed
    dcv_failed
    downloaded
    reissued
    expired
    expiring_soon
  ].freeze

  # Badge color helper
  def badge_color
    case action
    when 'issued', 'renewed', 'dcv_completed'
      'bg-green-100 text-green-800'
    when 'cancelled', 'revoked', 'expired'
      'bg-red-100 text-red-800'
    when 'dcv_sent', 'dcv_failed'
      'bg-yellow-100 text-yellow-800'
    when 'downloaded', 'reissued'
      'bg-blue-100 text-blue-800'
    when 'expiring_soon'
      'bg-orange-100 text-orange-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def formatted_action
    action.humanize
  end
end
