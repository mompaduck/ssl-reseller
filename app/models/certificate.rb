class Certificate < ApplicationRecord
  belongs_to :order
  belongs_to :user
  has_many :audit_logs, as: :auditable, dependent: :destroy
  has_many :certificate_logs, dependent: :destroy

  enum :status, {
    pending: 0,
    issued: 1,
    expired: 2,
    dcv_failed: 4,
    canceled: 5
  }, default: :pending

  enum :certificate_type, {
    dv: 0,
    ov: 1,
    ev: 2
  }, default: :dv, prefix: true

  validates :order_id, presence: true
  validates :user_id, presence: true
  validates :serial_number, uniqueness: true, allow_nil: true
  validates :certificate_body, presence: true, if: :issued?
  validates :expires_at, presence: true, if: :issued?

  scope :recent, -> { order(issued_at: :desc) }
  scope :active, -> { issued.where("expires_at > ?", Time.current) }

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def revoke!
    revoked!
    update!(revoked_at: Time.current)
  end
end
