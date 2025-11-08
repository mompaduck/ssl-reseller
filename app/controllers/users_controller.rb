class UsersController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    @user = current_user
    # 필요한 정보 예: @orders = @user.orders
  end

  def orders
    @user = current_user
    @orders = @user.orders.order(created_at: :desc)
  end
end