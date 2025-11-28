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
  
  # Turbo Stream broadcasts
  after_update_commit :broadcast_status_update, if: :saved_change_to_status?
  after_update_commit :broadcast_dcv_failure, if: -> { dcv_failed? && status_previously_was != 'dcv_failed' }

  scope :recent, -> { order(issued_at: :desc) }
  scope :active, -> { issued.where("expires_at > ?", Time.current) }

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def revoke!
    revoked!
    update!(revoked_at: Time.current)
  end
  
  def broadcast_status_update
    # Update certificate card in admin view
    broadcast_replace_to(
      "admin_certificates",
      target: "certificate_#{id}",
      partial: "admin/certificates/certificate_card",
      locals: { certificate: self }
    )
    
    # Update in user's certificate list
    broadcast_replace_to(
      "user_#{user_id}_certificates",
      target: "certificate_#{id}",
      partial: "certificates/certificate_card",
      locals: { certificate: self }
    )
    
    # Update certificate status badge
    broadcast_update_to(
      "certificate_#{id}_status",
      target: "certificate_status_#{id}",
      html: "<span class='badge badge-#{status}'>#{status.titleize}</span>"
    )
    
    # Update dashboard certificate status card
    broadcast_certificate_status_card
  end
  
  def broadcast_dcv_failure
    # Notify admin of DCV failure
    broadcast_prepend_to(
      "admin_notifications",
      target: "admin_notifications",
      partial: "admin/notifications/dcv_failure",
      locals: { certificate: self }
    )
    
    # Update dashboard certificate status card (DCV failure indicator)
    broadcast_certificate_status_card
  end
  
  def broadcast_certificate_status_card
    # Query certificate data directly
    today_start = Time.current.beginning_of_day
    pending_certificates_count = Certificate.where(status: :pending).count
    issued_certificates_count = Certificate.where(status: :issued).count
    dcv_failed_count = Certificate.where(status: :dcv_failed).count
    expired_certificates_count = Certificate.where(status: :expired).count
    today_issued_certificates = Certificate.where(status: :issued)
                                          .where("issued_at >= ?", today_start)
                                          .includes(:order)
                                          .order(issued_at: :desc)
                                          .limit(5)
    
    broadcast_replace_to(
      "dashboard_updates",
      target: "certificate_status_card",
      partial: "admin/dashboard/certificate_status_card",
      locals: {
        pending_certificates_count: pending_certificates_count,
        issued_certificates_count: issued_certificates_count,
        dcv_failed_count: dcv_failed_count,
        expired_certificates_count: expired_certificates_count,
        today_issued_certificates: today_issued_certificates
      }
    )
  end
end
