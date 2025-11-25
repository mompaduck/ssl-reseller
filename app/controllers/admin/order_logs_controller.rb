module Admin
  class OrderLogsController < BaseController
    def index
      @order_logs = OrderLog.includes(:order, :user).recent

      # Apply filters
      @order_logs = @order_logs.by_action(params[:action_type]) if params[:action_type].present?
      @order_logs = @order_logs.by_user(params[:user_id]) if params[:user_id].present?
      @order_logs = @order_logs.search(params[:q]) if params[:q].present?
      
      # Date range filter
      if params[:start_date].present? && params[:end_date].present?
        @order_logs = @order_logs.by_date_range(
          Date.parse(params[:start_date]),
          Date.parse(params[:end_date])
        )
      end

      @order_logs = @order_logs.page(params[:page]).per(50)
      
      # For filter dropdowns
      @action_types = OrderLog::ACTION_TYPES
    end
  end
end
