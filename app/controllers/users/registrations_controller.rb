# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action { request.env["devise.mapping"] = Devise.mappings[:user] }
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def check_email
    email = params[:email].to_s.strip.downcase
    exists = User.exists?(email: email)
    render json: { exists: exists }
  end

  # Override update to track changes
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    
    # Track what's being changed
    changed_fields = []
    is_password_change = params[:user][:password].present?
    
    # Detect profile changes
    %w[name email company_name phone country].each do |field|
      if params[:user][field.to_sym].present? && params[:user][field.to_sym] != resource.send(field)
        changed_fields << field
      end
    end

    prev_attributes = resource.attributes.slice('name', 'email', 'company_name', 'phone', 'country')
    
    super do |resource|
      if resource.errors.empty?
        # Log password change
        if is_password_change
          AuditLogger.log(
            resource,
            resource,
            'password_change',
            "비밀번호 변경",
            {},
            request.remote_ip
          )
        end
        
        # Log profile update
        if changed_fields.any?
          changes = {}
          changed_fields.each do |field|
            changes[field] = { from: prev_attributes[field], to: resource.send(field) }
          end
          
          AuditLogger.log(
            resource,
            resource,
            'profile_update',
            "프로필 정보 수정: #{changed_fields.join(', ')}",
            changes,
            request.remote_ip
          )
        end
      end
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
      