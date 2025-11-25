class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true
end
