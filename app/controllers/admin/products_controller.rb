class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :toggle_active, :clone]
  
  def index
    @products = Product.all
    
    # 필터 적용
    @products = @products.where(provider: params[:provider]) if params[:provider].present?
    @products = @products.where(validation_type: params[:validation_type]) if params[:validation_type].present?
    @products = @products.where(domain_type: params[:domain_type]) if params[:domain_type].present?
    @products = @products.where(is_active: params[:is_active]) if params[:is_active].present?
    
    # 정렬
    @products = @products.order(created_at: :desc).page(params[:page]).per(30)
    
    # 통계
    @total_products = Product.count
    @active_products = Product.active.count
    @on_promotion = Product.on_promotion.count
  end
  
  def show
  end
  
  def new
    @product = Product.new
  end
  
  def create
    @product = Product.new(product_params)
    
    if @product.save
      AuditLogger.log(
        current_user,
        @product,
        'create',
        "상품 생성: #{@product.name}",
        product_params.to_h,
        request.remote_ip
      )
      redirect_to admin_products_path, notice: '상품이 생성되었습니다.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    old_values = {
      cost_price: @product.cost_price,
      selling_price: @product.selling_price,
      discount: @product.discount
    }
    
    if @product.update(product_params)
      changes = {}
      [:cost_price, :selling_price, :discount].each do |attr|
        if old_values[attr] != @product.send(attr)
          changes[attr] = { from: old_values[attr], to: @product.send(attr) }
        end
      end
      
      AuditLogger.log(
        current_user,
        @product,
        'update',
        "상품 수정: #{@product.name}",
        changes,
        request.remote_ip
      )
      
      redirect_to admin_products_path, notice: '상품이 수정되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    name = @product.name
    @product.destroy
    
    AuditLogger.log(
      current_user,
      @product,
      'destroy',
      "상품 삭제: #{name}",
      {},
      request.remote_ip
    )
    
    redirect_to admin_products_path, notice: '상품이 삭제되었습니다.'
  end
  
  def toggle_active
    @product.update(is_active: !@product.is_active)
    
    AuditLogger.log(
      current_user,
      @product,
      'toggle_active',
      "상품 #{@product.is_active ? '활성화' : '비활성화'}: #{@product.name}",
      { is_active: @product.is_active },
      request.remote_ip
    )
    
    redirect_to admin_products_path, notice: "상품이 #{@product.is_active ? '활성화' : '비활성화'}되었습니다."
  end
  
  def clone
    new_product = @product.dup
    new_product.product_code = "#{@product.product_code}_COPY_#{Time.current.to_i}"
    new_product.name = "#{@product.name} (복사본)"
    new_product.is_active = false
    
    if new_product.save
      AuditLogger.log(
        current_user,
        new_product,
        'clone',
        "상품 복제: #{@product.name} → #{new_product.name}",
        { original_id: @product.id },
        request.remote_ip
      )
      
      redirect_to edit_admin_product_path(new_product), notice: '상품이 복제되었습니다. 수정 후 저장하세요.'
    else
      redirect_to admin_products_path, alert: '상품 복제에 실패했습니다.'
    end
  end
  
  private
  
  def set_product
    @product = Product.find(params[:id])
  end
  
  def product_params
    params.require(:product).permit(
      :name, :provider, :product_code, :description,
      :duration_months, :cost_price, :selling_price, :discount,
      :domain_count, :domain_type, :validation_type,
      :liability_usd, :promo_code, :promo_valid_until,
      :is_on_promotion, :is_active, :features
    )
  end
end
