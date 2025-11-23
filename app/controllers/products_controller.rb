class ProductsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @products = Product.active

    # -----------------------------------------
    # 1) 인증기관 (문자열 기반 필터링)
    # DB에 저장된 값 예 → "Sectigo", "DigiCert"
    # -----------------------------------------
    if params[:provider].present?
      @products = @products.where(provider: params[:provider])
    end

    # -----------------------------------------
    # 2) 검증 타입 (DV, OV, EV)
    # -----------------------------------------
    if params[:validation_type].present?
      vt = params[:validation_type].to_s.downcase
      if Product.validation_types.key?(vt)
        @products = @products.where(validation_type: Product.validation_types[vt])
      end
    end

    # -----------------------------------------
    # 3) 도메인 타입 (single, wildcard, multi)
    # -----------------------------------------
    if params[:domain_type].present? && Product.domain_types.key?(params[:domain_type])
      @products = @products.where(domain_type: Product.domain_types[params[:domain_type]])
    end

    @products = @products.order(provider: :asc, price: :asc)
  end

  def show
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "존재하지 않는 상품입니다."
  end
end