# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action { request.env["devise.mapping"] = Devise.mappings[:user] }
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # 이메일 중복 확인 (AJAX)
  def check_email
    email = params[:email].to_s.strip.downcase
    exists = User.exists?(email: email)
    render json: { exists: exists }
  end

  # 회원가입 처리 오버라이드
  def create
    build_resource(sign_up_params)

    resource.save
    if resource.persisted?
      if resource.active_for_authentication?
        flash[:notice] = "회원가입이 완료되었습니다."
        sign_up(resource_name, resource)
        redirect_to after_sign_up_path_for(resource)
      else
        flash[:notice] = "회원가입이 완료되었지만, 활성화가 필요합니다."
        expire_data_after_sign_in!
        redirect_to after_inactive_sign_up_path_for(resource)
      end
    else
      flash.now[:alert] = resource.errors.full_messages.join(" / ")
      clean_up_passwords(resource)
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  # 수정 처리 방식 오버라이드
  def update_resource(resource, params)
    if params[:password].present? || params[:password_confirmation].present?
      # 비밀번호 변경 + current_password 확인 필요
      resource.update_with_password(params)
    else
      # 비밀번호 변경 없음 → current_password 제거 후 정보만 업데이트
      params.delete(:current_password)
      params.delete(:password) if params[:password].blank?
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
      resource.update_without_password(params)
    end
  end

  # 수정 완료 후 경로
  def after_update_path_for(resource)
    edit_user_registration_path
  end

  # Devise 허용할 파라미터 설정 – 회원가입
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :company_name, :phone, :country, :email, :password, :password_confirmation, :terms])
  end

  # Devise 허용할 파라미터 설정 – 계정 수정
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name, :company_name, :phone, :country,
      :email, :password, :password_confirmation, :current_password
    ])
  end

  private

  def log_deletion_reason(user, params)
    Rails.logger.info "[Account Deletion] User: #{user.email}, Reason: #{params[:deletion_reason]}, Comment: #{params[:deletion_comment]}"
  end
end