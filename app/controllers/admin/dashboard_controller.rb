module Admin
  class DashboardController < BaseController
    def index
      load_order_summary
      load_certificate_status
      load_ticket_status
      load_system_alerts
      load_revenue_summary
    end

    private

    def load_order_summary
      today_start = Time.current.beginning_of_day
      
      # Today's order counts
      @today_orders_count = Order.where("created_at >= ?", today_start).count
      @paid_orders_count = Order.where("created_at >= ?", today_start).where(status: :paid).count
      @pending_orders_count = Order.where("created_at >= ?", today_start).where(status: :pending).count
      @cancelled_orders_count = Order.where("created_at >= ?", today_start).where(status: [:cancelled, :refunded]).count
      @today_revenue = Order.where("created_at >= ?", today_start).where(status: :paid).sum(:total_price)
    end

    def load_certificate_status
      today_start = Time.current.beginning_of_day
      
      # Certificate status counts
      @pending_certificates_count = Certificate.where(status: :pending).count
      @issued_certificates_count = Certificate.where(status: :issued).count
      @dcv_failed_count = Certificate.where(status: :dcv_failed).count
      @expired_certificates_count = Certificate.where(status: :expired).count
      
      # Today's issued certificates
      @today_issued_certificates = Certificate.where(status: :issued)
                                              .where("issued_at >= ?", today_start)
                                              .includes(:order)
                                              .order(issued_at: :desc)
                                              .limit(5)
    end

    def load_ticket_status
      # Ticket status counts
      @open_tickets_count = Ticket.where(status: [:new, :open]).count
      @pending_tickets_count = Ticket.where(status: :pending).count
      @resolved_tickets_count = Ticket.where(status: :resolved).count
      
      # Count both unread messages AND new tickets as notifications
      unread_messages = TicketMessage.where(message_type: :customer, read_at: nil).count
      new_tickets = Ticket.where(status: :new).count
      @unread_messages_count = unread_messages + new_tickets
      
      # Recent tickets (last 5)
      @recent_tickets = Ticket.includes(:user)
                             .where(status: [:new, :open])
                             .order(created_at: :desc)
                             .limit(5)
    end

    def load_system_alerts
      thirty_minutes_ago = 30.minutes.ago
      today_start = Time.current.beginning_of_day
      
      # API errors in last 30 minutes
      @api_errors_count = PartnerApiLog.where(status: 'error')
                                      .where("created_at >= ?", thirty_minutes_ago)
                                      .count
      
      # Recent API error logs
      @recent_api_errors = PartnerApiLog.where(status: 'error')
                                       .where("created_at >= ?", thirty_minutes_ago)
                                       .includes(:order)
                                       .order(created_at: :desc)
                                       .limit(5)
      
      # Email failures (placeholder - implement when notification system is ready)
      @email_failures_count = NotificationLog.where(status: :failed)
                                            .where("created_at >= ?", today_start)
                                            .count rescue 0
    end

    def load_revenue_summary
      today_start = Time.current.beginning_of_day
      month_start = Time.current.beginning_of_month
      
      # Today's stats
      @today_orders_count = Order.where("created_at >= ?", today_start).count
      @today_revenue = Order.where("created_at >= ?", today_start).where(status: :paid).sum(:total_price)
      
      # This month's stats
      @month_orders_count = Order.where("created_at >= ?", month_start).count
      @month_revenue = Order.where("created_at >= ?", month_start).where(status: :paid).sum(:total_price)
      
      # Calculations
      @average_order_value = @month_orders_count > 0 ? (@month_revenue / @month_orders_count).to_i : 0
      @estimated_profit = (@month_revenue * 0.3).to_i
    end
  end
end
