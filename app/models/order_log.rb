class OrderLog < ApplicationRecord
  belongs_to :order
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
      joins(:order).joins("LEFT JOIN users ON users.id = order_logs.user_id")
        .where("order_logs.message LIKE ? OR orders.internal_order_id LIKE ? OR users.name LIKE ?", 
               "%#{query}%", "%#{query}%", "%#{query}%")
    end
  }

  # Action types
  ACTION_TYPES = %w[
    created
    status_changed
    payment_completed
    payment_failed
    refunded
    cancelled
    updated
  ].freeze

  # Badge color helper
  def badge_color
    case action
    when 'created'
      'bg-blue-100 text-blue-800'
    when 'status_changed'
      'bg-purple-100 text-purple-800'
    when 'payment_completed'
      'bg-green-100 text-green-800'
    when 'payment_failed'
      'bg-red-100 text-red-800'
    when 'refunded'
      'bg-orange-100 text-orange-800'
    when 'cancelled'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def formatted_action
    action.humanize
  end
end
