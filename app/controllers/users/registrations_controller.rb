class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action { request.env["devise.mapping"] = Devise.mappings[:user] }

  # 회원가입 및 수정 파라미터 허용
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # 이메일 중복 확인용 액션 (AJAX)
  def check_email
    email = params[:email].to_s.strip.downcase
    exists = User.exists?(email: email)
    render json: { exists: exists }
  end


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
      # 오류가 있을 때: 오류 메시지를 플래시에 담음
      flash.now[:alert] = resource.errors.full_messages.join(" / ")
      clean_up_passwords(resource)
      set_minimum_password_length
      respond_with resource
    end
  end

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_inactive_sign_up_path_for(resource)
    root_path
  end

  
  # 계정 삭제 페이지 (GET)
  def delete
    @user = current_user
  end

  # 계정 삭제 처리 (DELETE)
  def destroy
    current_password = params.dig(:user, :current_password)
    
    if current_password.blank?
      redirect_to delete_user_registration_path, alert: "비밀번호를 입력해주세요."
      return
    end

    unless resource.valid_password?(current_password)
      redirect_to delete_user_registration_path, alert: "비밀번호가 올바르지 않습니다."
      return
    end

    deletion_reason = params.dig(:user, :deletion_reason)
    log_deletion_reason(resource, params[:user]) if deletion_reason.present?

    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message! :notice, :destroyed
    respond_with_navigational(resource) { redirect_to deleted_user_registration_path }
  end

  protected

  # 수정 처리 오버라이드
  protected
  def update_resource(resource, params)
    # 비밀번호 변경을 포함하는지 체크
    if params[:password].present? || params[:password_confirmation].present?
      # 비밀번호 변경이 포함된 경우: 현재 비밀번호를 확인해야 함
      resource.update_with_password(params)
    else
      # 비밀번호 변경이 없는 경우: current_password 제거하고 비밀번호 없이 업데이트
      params.delete(:current_password)
      resource.update_without_password(params)
    end
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation, :terms])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name, :company_name, :phone, 
      :email, :password, :password_confirmation, :current_password
    ])
  end

  private

  def log_deletion_reason(user, params)
    Rails.logger.info "[Account Deletion] User: #{user.email}, Reason: #{params[:deletion_reason]}, Comment: #{params[:deletion_comment]}"
  end

  

end