module Admin
  class CertificateLogsController < BaseController
    def index
      @certificate_logs = CertificateLog.includes(:certificate, :user).recent

      # Apply filters
      @certificate_logs = @certificate_logs.by_action(params[:action_type]) if params[:action_type].present?
      @certificate_logs = @certificate_logs.by_user(params[:user_id]) if params[:user_id].present?
      @certificate_logs = @certificate_logs.search(params[:q]) if params[:q].present?
      
      # Date range filter
      if params[:start_date].present? && params[:end_date].present?
        @certificate_logs = @certificate_logs.by_date_range(
          Date.parse(params[:start_date]),
          Date.parse(params[:end_date])
        )
      end

      @certificate_logs = @certificate_logs.page(params[:page]).per(50)
      
      # For filter dropdowns
      @action_types = CertificateLog::ACTION_TYPES
    end
  end
end
