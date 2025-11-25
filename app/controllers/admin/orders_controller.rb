module Admin
  class OrdersController < BaseController
    def index
      @orders = current_user.accessible_orders.includes(:user, :product).order(created_at: :desc).page(params[:page]).per(20)
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
