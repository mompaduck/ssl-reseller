# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  # Devise 매핑 보정 (custom route 및 중복확인에서 필요)
  prepend_before_action { request.env["devise.mapping"] = Devise.mappings[:user] }

  # 회원가입 시 허용할 파라미터 확장
  before_action :configure_sign_up_params, only: [:create]
  # 회원정보 수정 시 허용할 파라미터 확장
  before_action :configure_account_update_params, only: [:update]

  # 이메일 중복 확인용 액션 (AJAX)
  def check_email
    email = params[:email].to_s.strip.downcase
    exists = User.exists?(email: email)
    render json: { exists: exists }
  end

  protected

  # Devise strong parameters – 가입 시

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation, :terms])
  end

  # Devise strong parameters – 수정 시
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name, :company_name, :phone, :country, :email, :password, :password_confirmation, :current_password
    ])
  end
  
  # DELETE /users
  #def destroy
    # 현재 사용자의 계정을 삭제하고 '완료' 페이지로 리디렉트
   # resource.destroy
    #Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    #set_flash_message! :notice, :destroyed
    #yield resource if block_given?
    # 리디렉션 경로를 ‘삭제 완료’ 페이지로 지정
    #respond_with_navigational(resource){ redirect_to deleted_user_registration_path }
  #end
end