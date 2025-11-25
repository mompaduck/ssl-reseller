class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  # Scopes for filtering
  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) if action.present? }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_date_range, ->(start_date, end_date) {
    where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date.present? && end_date.present?
  }
  scope :search, ->(query) {
    if query.present?
      joins("LEFT JOIN users ON users.id = audit_logs.user_id")
        .where("audit_logs.message LIKE ? OR users.name LIKE ? OR users.email LIKE ?", 
               "%#{query}%", "%#{query}%", "%#{query}%")
    end
  }

  # Action types for filtering
  ACTION_TYPES = %w[
    login
    role_change
    partner_assignment
    suspend
    activate
    soft_delete
    reset_password
    confirm_email
    unconfirm_email
    profile_update
    password_change
    status_change
    payment_success
    payment_failed
    refund
    reissue
    cancel
    resend_dcv
    send_reminder
  ].freeze

  # Badge color helper
  def badge_color
    case action
    when 'login'
      'bg-green-100 text-green-800'
    when 'role_change', 'partner_assignment'
      'bg-purple-100 text-purple-800'
    when 'suspend', 'soft_delete', 'cancel'
      'bg-red-100 text-red-800'
    when 'activate', 'confirm_email'
      'bg-green-100 text-green-800'
    when 'reset_password', 'password_change', 'unconfirm_email'
      'bg-yellow-100 text-yellow-800'
    when 'profile_update'
      'bg-blue-100 text-blue-800'
    when 'payment_success'
      'bg-emerald-100 text-emerald-800'
    when 'payment_failed'
      'bg-red-100 text-red-800'
    when 'refund'
      'bg-orange-100 text-orange-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  # Format action for display
  def formatted_action
    action.humanize
  end
end
