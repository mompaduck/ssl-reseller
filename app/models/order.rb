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

  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :active, -> { where(status: [:pending, :paid, :issued]) }

  private

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
end
