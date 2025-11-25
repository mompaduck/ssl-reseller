class Payment < ApplicationRecord
  belongs_to :order

  enum :status, {
    pending: 0,
    succeeded: 1,
    failed: 2,
    refunded: 3
  }, default: :pending

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :transaction_id, presence: true, uniqueness: true, allow_nil: true

  # Audit logging for payment events
  after_commit :log_payment_success, if: -> { saved_change_to_status? && succeeded? }
  after_commit :log_payment_failure, if: -> { saved_change_to_status? && failed? }
  after_commit :log_payment_refund, if: -> { saved_change_to_status? && refunded? }

  private

  def log_payment_success
    AuditLogger.log(
      order.user,
      self,
      'payment_success',
      "결제 성공 - Order ##{order.id} (#{amount}원)",
      { 
        order_id: order.id,
        amount: amount,
        payment_method: payment_method,
        transaction_id: transaction_id
      },
      nil
    )
  end

  def log_payment_failure
    AuditLogger.log(
      order.user,
      self,
      'payment_failed',
      "결제 실패 - Order ##{order.id}",
      { 
        order_id: order.id,
        amount: amount,
        payment_method: payment_method
      },
      nil
    )
  end

  def log_payment_refund
    AuditLogger.log(
      order.user,
      self,
      'refund',
      "환불 처리 - Order ##{order.id} (#{amount}원)",
      { 
        order_id: order.id,
        amount: amount,
        transaction_id: transaction_id
      },
      nil
    )
  end
end
