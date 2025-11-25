class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:confirm]

  def dashboard
    @user = current_user
    # 예: @orders = @user.orders
  end

  def orders
    @user = current_user
    @orders = @user.orders.order(created_at: :desc)
  end

  # 🔥 이메일 인증 처리
  def confirm
    user = User.find_by(confirmation_token: params[:token])

    if user.present?
      user.update(confirmed_at: Time.current, confirmation_token: nil)
      redirect_to root_path, notice: "이메일 인증이 완료되었습니다!"
    else
      redirect_to root_path, alert: "잘못되었거나 만료된 인증 링크입니다."
    end
  end
end