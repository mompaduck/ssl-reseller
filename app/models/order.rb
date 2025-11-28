class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_one :certificate, dependent: :destroy
  has_many :audit_logs, as: :auditable, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :partner_api_logs, dependent: :destroy
  has_many :order_logs, dependent: :destroy

  enum :status, {
    pending: 'pending',
    paid: 'paid',
    cancelled: 'cancelled',
    refunded: 'refunded',
    expired: 'expired'
  }, default: 'pending'

  enum :certificate_type, {
    dv: 'dv',
    ov: 'ov',
    ev: 'ev'
  }

  validates :certificate_type, presence: true
  validates :domain, presence: true
  validates :name, presence: true
  validates :english_name, presence: true, if: :ov_or_ev_certificate?
  validates :company_name, presence: true
  validates :phone, presence: true
  validates :user_id, presence: true
  validates :product_id, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :total_price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true


  before_create :generate_order_number
  before_validation :set_defaults, on: :create
  before_save :normalize_phone
  
  # Turbo Stream broadcasts
  after_create_commit :broadcast_new_order
  after_update_commit :broadcast_status_change, if: :saved_change_to_status?

  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :active, -> { where(status: [:pending, :paid, :issued]) }


  private

  def normalize_phone
    self.phone = phone.gsub('-', '') if phone.present?
  end

  def generate_order_number
    return if internal_order_id.present?
    
    date_prefix = Time.current.strftime('%y%m%d')
    
    # 트랜잭션으로 동시성 문제 방지
    ActiveRecord::Base.transaction do
      # 오늘 날짜의 마지막 주문번호 찾기
      last_order = Order.lock.where("internal_order_id LIKE ?", "#{date_prefix}-%")
                        .order(internal_order_id: :desc)
                        .first
      
      sequence = if last_order && last_order.internal_order_id.present?
                   # 마지막 번호에서 추출하여 +1
                   last_order.internal_order_id.split('-').last.to_i + 1
                 else
                   # 오늘 첫 주문
                   1
                 end
      
      # 형식: YYMMDD-XXXXX (예: 241124-00001)
      self.internal_order_id = "#{date_prefix}-#{sequence.to_s.rjust(5, '0')}"
    end
  end

  def set_defaults
    self.status ||= :pending
  end


  def ov_or_ev_certificate?
    ['ov', 'ev'].include?(certificate_type)
  end
  
  def broadcast_new_order
    Rails.logger.info "📢 Broadcasting new order #{id} to admin_orders stream"
    # Broadcast to admin order list
    broadcast_prepend_to(
      "admin_orders",
      target: "orders_table_body",
      partial: "admin/orders/order_table_row",
      locals: { order: self }
    )
    
    # Update dashboard order summary card
    broadcast_order_summary_card
  end
  
  def broadcast_status_change
    # Update order row in admin list
    broadcast_replace_to(
      "admin_orders",
      target: "order_#{id}",
      partial: "admin/orders/order_table_row",
      locals: { order: self }
    )
    
    # Update in user's order list if viewing
    broadcast_replace_to(
      "user_#{user_id}_orders",
      target: "order_#{id}",
      partial: "orders/order_row",
      locals: { order: self }
    )
    
    # Update dashboard order summary card
    broadcast_order_summary_card
  end
  
  def broadcast_order_summary_card
    # Query order data directly
    today_start = Time.current.beginning_of_day
    today_orders_count = Order.where("created_at >= ?", today_start).count
    paid_orders_count = Order.where("created_at >= ?", today_start).where(status: :paid).count
    pending_orders_count = Order.where("created_at >= ?", today_start).where(status: :pending).count
    cancelled_orders_count = Order.where("created_at >= ?", today_start).where(status: [:cancelled, :refunded]).count
    today_revenue = Order.where("created_at >= ?", today_start).where(status: :paid).sum(:total_price)
    
    broadcast_replace_to(
      "dashboard_updates",
      target: "order_summary_card",
      partial: "admin/dashboard/order_summary_card",
      locals: {
        today_orders_count: today_orders_count,
        paid_orders_count: paid_orders_count,
        pending_orders_count: pending_orders_count,
        cancelled_orders_count: cancelled_orders_count,
        today_revenue: today_revenue
      }
    )
  end
end
