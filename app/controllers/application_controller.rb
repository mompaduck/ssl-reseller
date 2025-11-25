class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # 1️⃣ 모든 요청에 로그인 필터 적용 (로그인 안하면 /users/sign_in 으로 이동)
  before_action :authenticate_user!

  # 2️⃣ Devise strong parameter 설정 (회원가입 / 수정 시 추가 필드 허용)
  before_action :configure_permitted_parameters, if: :devise_controller?

  # ✅ 로그인 성공 후 이동 경로 커스터마이징
  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.can_access_admin?
      admin_root_path
    else
      root_path
    end
  end

  # ✅ 로그아웃 후 이동 경로
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  protected

  # ✅ 회원가입 시 허용할 추가 필드 지정
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :company_name, :phone, :terms
    ])

    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name, :company_name, :phone, :terms
    ])
  end
end