class AuditLogger
  def self.log(actor, auditable, action, message, metadata = {}, ip_address = nil)
    AuditLog.create!(
      user: actor.is_a?(User) ? actor : nil,
      auditable: auditable,
      action: action,
      message: message,
      metadata: metadata,
      ip_address: ip_address
    )
  end
end
