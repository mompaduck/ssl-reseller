module Admin
  class DashboardController < BaseController
    def index
      # Today's stats
      @today_orders = Order.where("created_at >= ?", Time.current.beginning_of_day).count
      @today_revenue = Order.where("created_at >= ?", Time.current.beginning_of_day).sum(:total_price)
      
      # This month's stats
      @month_orders = Order.where("created_at >= ?", Time.current.beginning_of_month).count
      @month_revenue = Order.where("created_at >= ?", Time.current.beginning_of_month).sum(:total_price)
      
      # Certificate stats
      @issued_certificates = Certificate.issued.count
      @issued_this_month = Certificate.issued.where("issued_at >= ?", Time.current.beginning_of_month).count
      @dcv_failed = Certificate.where(status: :dcv_failed).count
      @pending_certificates = Certificate.pending.count
      @expiring_soon = Certificate.issued.where(expires_at: Time.current..30.days.from_now).count
      
      # Revenue
      @total_revenue = Order.sum(:total_price)
      @estimated_profit = @total_revenue * 0.3 # Assuming 30% profit margin
      
      # API Errors
      @api_errors_today = PartnerApiLog.where(status: 'error').where("created_at >= ?", Time.current.beginning_of_day).count
      @api_errors_total = PartnerApiLog.where(status: 'error').count
      
      # Recent activities (Audit Logs)
      @recent_activities = AuditLog.includes(:user, :auditable).order(created_at: :desc).limit(10)
      
      # Recent orders
      @recent_orders = Order.includes(:user, :product).order(created_at: :desc).limit(5)
    end
  end
end
