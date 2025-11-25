module Admin
  class SystemLogsController < BaseController
    def index
      @system_logs = SystemLog.recent

      # Apply filters
      @system_logs = @system_logs.by_level(params[:level]) if params[:level].present?
      @system_logs = @system_logs.by_source(params[:source]) if params[:source].present?
      @system_logs = @system_logs.search(params[:q]) if params[:q].present?
      
      # Date range filter
      if params[:start_date].present? && params[:end_date].present?
        @system_logs = @system_logs.by_date_range(
          Date.parse(params[:start_date]),
          Date.parse(params[:end_date])
        )
      end

      @system_logs = @system_logs.page(params[:page]).per(50)
      
      # For filter dropdowns
      @sources = SystemLog.distinct.pluck(:source).compact.sort
    end
  end
end
