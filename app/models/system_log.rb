class SystemLog < ApplicationRecord
  # Enums
  enum :level, {
    info: 0,
    warning: 1,
    error: 2,
    critical: 3
  }, default: :info

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_level, ->(level) { where(level: level) if level.present? }
  scope :by_source, ->(source) { where(source: source) if source.present? }
  scope :by_date_range, ->(start_date, end_date) {
    where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date.present? && end_date.present?
  }
  scope :search, ->(query) {
    where("source LIKE ? OR message LIKE ?", "%#{query}%", "%#{query}%") if query.present?
  }

  # Badge color helper
  def badge_color
    case level
    when 'info'
      'bg-blue-100 text-blue-800'
    when 'warning'
      'bg-yellow-100 text-yellow-800'
    when 'error'
      'bg-red-100 text-red-800'
    when 'critical'
      'bg-red-600 text-white'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def formatted_level
    level.upcase
  end
end
