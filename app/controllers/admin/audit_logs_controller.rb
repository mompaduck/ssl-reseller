module Admin
  class AuditLogsController < BaseController
    def index
      @audit_logs = AuditLog.includes(:user, :auditable).recent

      # Apply filters
      @audit_logs = @audit_logs.by_action(params[:action_type]) if params[:action_type].present?
      @audit_logs = @audit_logs.search(params[:q]) if params[:q].present?
      
      # Date range filter
      if params[:start_date].present? && params[:end_date].present?
        @audit_logs = @audit_logs.by_date_range(
          Date.parse(params[:start_date]),
          Date.parse(params[:end_date])
        )
      end

      @audit_logs = @audit_logs.page(params[:page]).per(30)
      
      # For filter dropdowns
      @action_types = AuditLog::ACTION_TYPES
    end
  end
end
