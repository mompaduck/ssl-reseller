class Users::RegistrationsController < Devise::RegistrationsController
  # Devise 매핑 보정 (중복확인 등 custom route에서 필요)
  prepend_before_action { request.env["devise.mapping"] = Devise.mappings[:user] }

  # 회원가입 시 허용할 파라미터 확장
  before_action :configure_sign_up_params, only: [:create]

  # 이메일 중복 확인용 액션 (AJAX)
  def check_email
    email = params[:email].to_s.strip.downcase
    exists = User.exists?(email: email)
    render json: { exists: exists }
  end

  protected

  # Devise strong parameters 확장
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :email, :password, :password_confirmation, :terms
    ])
  end

  private

  # 혹시 sign_up_params를 직접 호출하는 경우를 대비해 그대로 둠
  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :terms)
  end
end