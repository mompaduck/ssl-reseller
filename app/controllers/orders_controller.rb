class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :pay]

  def new
    # Get certificate_type from params and convert to string
    cert_type = params[:certificate_type]&.to_s || 'dv'
    
    # Validate it's a valid type
    valid_types = ['dv', 'ov', 'ev']
    @certificate_type = valid_types.include?(cert_type) ? cert_type : 'dv'
    
    # Pre-fill user information from current_user
    @order = Order.new(
      certificate_type: @certificate_type,
      name: current_user.name,
      english_name: current_user.english_name,
      company_name: current_user.company_name,
      phone: current_user.phone,
      company_address: current_user.address
    )
  end

  def create
    @order = current_user.orders.build(order_params)
    
    # Calculate price based on product (simplified logic)
    # In a real app, fetch price from Product model
    product = Product.find_by(name: @order.certificate_type) # Assuming mapping exists or use ID
    # For now, just setting a default price if not set
    @order.total_price ||= 10000 
    @order.product = Product.first # Fallback for now to avoid validation error

    if @order.save
      # Log order creation in Order Log
      OrderLog.create!(
        order: @order,
        user: current_user,
        action: 'created',
        message: "주문 생성: #{@order.internal_order_id} - #{@order.domain}",
        metadata: {
          order_id: @order.internal_order_id,
          domain: @order.domain,
          certificate_type: @order.certificate_type,
          total_price: @order.total_price
        },
        ip_address: request.remote_ip
      )
      
      redirect_to @order, notice: "주문이 생성되었습니다. 결제를 진행해주세요."
    else
      # Set @certificate_type for the view when validation fails
      @certificate_type = @order.certificate_type || 'dv'
      flash.now[:alert] = "주문 생성 중 오류가 발생했습니다."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # Payment status check
  end

  def index
    @orders = current_user.orders.recent.includes(:product, :certificate)
  end

  def my_orders
    @orders = current_user.orders.recent.includes(:product, :certificate)
    render :index
  end

  def pay
    # GET request: show payment page
    if request.get?
      # Just render the payment page with order info
      return
    end
    
    # POST request: process payment
    # This is a simplified payment processing action.
    # In production, this would handle Stripe callbacks or confirm PaymentIntent.
    
    old_status = @order.status
    
    # Simulate successful payment
    if @order.update(status: :paid)
      # Create Payment record
      payment = @order.payments.create!(
        amount: @order.total_price,
        payment_method: 'stripe',
        status: :succeeded,
        transaction_id: "tx_#{SecureRandom.hex(8)}"
      )

      # Log payment completion in Order Log
      OrderLog.create!(
        order: @order,
        user: current_user,
        action: 'payment_completed',
        message: "결제 완료: ₩#{@order.total_price}",
        metadata: {
          old_status: old_status,
          new_status: 'paid',
          amount: @order.total_price,
          payment_method: 'stripe',
          transaction_id: payment.transaction_id
        },
        ip_address: request.remote_ip
      )

      # Trigger SSL Order
      issue_certificate(@order)

      redirect_to @order, notice: "결제가 완료되고 인증서 발급이 요청되었습니다."
    else
      redirect_to @order, alert: "결제 처리 중 오류가 발생했습니다."
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:certificate_type, :domain, :name, :english_name, :company_name, :phone, :company_address, :product_id)
  end

  def issue_certificate(order)
    service = SslProviderService.new
    # Assuming CSR is generated or provided. For now, using a placeholder.
    csr = order.csr || "-----BEGIN CERTIFICATE REQUEST-----\nMOCK_CSR\n-----END CERTIFICATE REQUEST-----"
    
    result = service.place_order(order, csr)
    
    if result.success?
      order.update(status: :issued, partner_order_number: result.order_id)
      
      # Create Certificate record
      Certificate.create!(
        order: order,
        user: order.user,
        certificate_type: order.certificate_type,
        status: :issued,
        issued_at: Time.current,
        expires_at: 1.year.from_now,
        serial_number: SecureRandom.hex(10),
        certificate_body: service.fetch_certificate(result.order_id)
      )
    else
      Rails.logger.error "Failed to place order with partner: #{result.error}"
      # Handle failure (e.g., notify admin, retry job)
    end
  end
end