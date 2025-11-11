class ProductsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show] # 로그인 없이 접근 가능

  def index
    # 활성화된 상품만 정렬 (이름순 or 가격순)
    @products = Product.where(is_active: true)
                       .order(provider: :asc, price: :asc, name: :asc)

    # 로그 확인용
    Rails.logger.debug "🧩 Loaded #{@products.size} products for display"
  end

  def show
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "존재하지 않는 상품입니다."
  end
end