# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  # 1. CSRF 공격 방지 토큰 포함 (Rails 기본 설정)
  # protect_from_forgery with: :exception # Rails 5.2 이전 버전에서 사용
  
  # 2. 모든 요청에 인증 필터 적용 (Devise 사용)
  #    이 라인 때문에 로그인되지 않은 사용자는 /users/sign_in으로 리다이렉트됩니다.
  before_action :authenticate_user!
  
  # 3. 로그인 후 리디렉션 경로 커스터마이징 (선택 사항)
  #    로그인 성공 후 어디로 갈지 결정합니다. (기본값: root_path 또는 요청했던 페이지)
  def after_sign_in_path_for(resource)
    # 예: 관리자라면 관리자 대시보드로, 일반 사용자라면 일반 대시보드로 보냅니다.
    if resource.is_a?(User) && resource.admin?
      admin_dashboard_path
    else
      super
    end
  end

  # 4. 로그아웃 후 리디렉션 경로 커스터마이징 (선택 사항)
  def after_sign_out_path_for(resource_or_scope)
    # 로그아웃 후 랜딩 페이지로 이동합니다.
    root_path
  end
end