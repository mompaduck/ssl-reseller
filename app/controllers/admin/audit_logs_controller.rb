module Admin
  class AuditLogsController < BaseController
    def index
      @audit_logs = AuditLog.includes(:user, :auditable).order(created_at: :desc).page(params[:page]).per(50)
    end
  end
end
