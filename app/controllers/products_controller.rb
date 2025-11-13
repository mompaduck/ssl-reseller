class ProductsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    # 기본: 활성 상품만 불러오기
    @products = Product.active.order(provider: :asc, price: :asc, name: :asc)

    Rails.logger.debug "🧩 Loaded #{@products.size} active products"

    # Provider 필터
    if params[:provider].present?
      @products = @products.where(provider: params[:provider])
      Rails.logger.debug "🔎 Filter applied: provider=#{params[:provider]}"
    end

    # Category 필터
    if params[:category].present?
      @products = @products.where(category: params[:category])
      Rails.logger.debug "🔎 Filter applied: category=#{params[:category]}"
    end

    Rails.logger.debug "📦 Final filtered products count = #{@products.size}"
  end

  def show
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "존재하지 않는 상품입니다."
  end
end