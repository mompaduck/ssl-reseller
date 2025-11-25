module Admin
  class OrdersController < BaseController
    def index
      @orders = current_user.accessible_orders.includes(:user, :product, :certificate, :payments)
      
      # Search
      if params[:q].present?
        query = "%#{params[:q]}%"
        @orders = @orders.where(
          "orders.internal_order_id LIKE ? OR orders.domain LIKE ? OR users.email LIKE ?",
          query, query, query
        ).references(:users)
      end
      
      # Status Filter
      @orders = @orders.where(status: params[:status]) if params[:status].present?
      
      # Order Type Filter
      @orders = @orders.where(order_type: params[:order_type]) if params[:order_type].present?
      
      # Period Filter
      if params[:period].present?
        case params[:period]
        when 'today'
          @orders = @orders.where('orders.created_at >= ?', Time.current.beginning_of_day)
        when 'week'
          @orders = @orders.where('orders.created_at >= ?', 1.week.ago)
        when 'month'
          @orders = @orders.where('orders.created_at >= ?', 1.month.ago)
        when '3months'
          @orders = @orders.where('orders.created_at >= ?', 3.months.ago)
        when '6months'
          @orders = @orders.where('orders.created_at >= ?', 6.months.ago)
        end
      end
      
      # Certificate Type Filter
      @orders = @orders.where(certificate_type: params[:certificate_type]) if params[:certificate_type].present?
      
      # DCV Method Filter
      if params[:dcv_method].present?
        @orders = @orders.joins(:certificate).where(certificates: { dcv_method: params[:dcv_method] })
      end
      
      # Payment Status Filter
      if params[:payment_status].present?
        @orders = @orders.joins(:payments).where(payments: { status: params[:payment_status] })
      end
      
      @orders = @orders.order(created_at: :desc).page(params[:page]).per(20)
    end

    def show
      @order = Order.find(params[:id])
    end

    def update_status
      @order = Order.find(params[:id])
      
      if @order.update(status: params[:status])
        AuditLogger.log(current_user, @order, 'status_change', "주문 상태 변경: #{params[:status]}", { old_status: @order.status_previously_was, new_status: @order.status }, request.remote_ip)
        redirect_to admin_order_path(@order), notice: "주문 상태가 #{params[:status]}(으)로 변경되었습니다."
      else
        redirect_to admin_order_path(@order), alert: "상태 변경 실패"
      end
    end
  end
end
