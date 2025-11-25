module Admin
  class NotificationLogsController < BaseController
    def index
      @notification_logs = NotificationLog.recent

      # Apply filters
      @notification_logs = @notification_logs.by_type(params[:notification_type]) if params[:notification_type].present?
      @notification_logs = @notification_logs.by_status(params[:status]) if params[:status].present?
      @notification_logs = @notification_logs.search(params[:q]) if params[:q].present?
      
      # Date range filter
      if params[:start_date].present? && params[:end_date].present?
        @notification_logs = @notification_logs.by_date_range(
          Date.parse(params[:start_date]),
          Date.parse(params[:end_date])
        )
      end

      @notification_logs = @notification_logs.page(params[:page]).per(50)
    end
  end
end
