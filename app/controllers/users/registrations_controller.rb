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
        #flash[:notice] = I18n.t("devise.registrations.signed_up") # I18n.locale 작동 안함. 나중에 다시해야함
        sign_up(resource_name, resource)
        redirect_to after_sign_up_path_for(resource)
      else
        flash[:notice] = "회원가입이 완료되었지만, 활성화가 필요합니다."
        #flash[:notice] = I18n.t("devise.registrations.signed_up")
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

  # 수정 처리 방식 오버라이드 (Devise 공식 레시피 적용)
  def update_resource(resource, params)
    # 비밀번호 변경을 시도하는 경우, Devise의 기본 로직(super)을 따름
    # 이 경우, current_password가 필요함
    return super if params["password"].present?

    # 비밀번호 변경 없이 개인정보만 수정하는 경우
    # current_password 없이 업데이트를 허용
    resource.update_without_password(params.except(:current_password))
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
      end
      