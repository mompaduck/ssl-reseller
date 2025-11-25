module Admin
  class ApiLogsController < BaseController
    def index
      @api_logs = PartnerApiLog.includes(:order).recent

      # Apply filters
      if params[:q].present?
        @api_logs = @api_logs.joins(:order).where(
          "orders.order_number LIKE ? OR partner_api_logs.status LIKE ?",
          "%#{params[:q]}%", "%#{params[:q]}%"
        )
      end
      
      @api_logs = @api_logs.where(status: params[:status]) if params[:status].present?
      
      # Date range filter
      if params[:start_date].present? && params[:end_date].present?
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])
        @api_logs = @api_logs.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
      end

      @api_logs = @api_logs.page(params[:page]).per(50)
      
      # For filter dropdowns
      @statuses = PartnerApiLog.distinct.pluck(:status).compact.sort
    end
  end
end
