class Users::SessionsController < Devise::SessionsController
  layout 'application'  # ✅ Tailwind 포함된 메인 레이아웃 사용

  # 로그인 성공 후 이동 경로
  def after_sign_in_path_for(resource)
    flash[:notice] = "🎉 CertGate에 오신 걸 환영합니다!"
    root_path
  end
end