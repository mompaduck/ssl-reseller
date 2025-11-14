class OrdersController < ApplicationController
  before_action :authenticate_user!

  def new
    # certificate_type이 유효한 enum 키인지 확인, 아니면 기본값 :dv 사용
    @certificate_type = Certificate.certificate_types.key?(params[:certificate_type]) ? params[:certificate_type] : :dv
    @order = Order.new(certificate_type: @certificate_type)
  end

  def create
    @order = current_user.orders.build(order_params)
    if @order.save
      flash[:notice] = "주문이 성공적으로 생성되었습니다."
      redirect_to @order
    else
      flash.now[:alert] = "주문 생성 중 오류가 발생했습니다."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def order_params
    # 모든 사용자 입력 필드 포함 허용
    params.require(:order).permit(:certificate_type, :domain, :company_name, :phone, :company_address)
  end
end