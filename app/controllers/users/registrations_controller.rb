# app/controllers/users/registrations_controller.rb
require 'ostruct'

class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action { request.env["devise.mapping"] = Devise.mappings[:user] }
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def check_email
    email = params[:email].to_s.strip.downcase
    user = User.find_by(email: email)
    
    if user
      render json: { exists: true, deleted: user.deleted? }
    else
      render json: { exists: false }
    end
  end

  # Show delete account page
  def delete
    @resource = current_user
    self.resource = @resource
    render :delete
  end

  # Override sign_up to prevent auto-login after registration
  def sign_up(resource_name, resource)
    # Do nothing - don't sign in the user automatically
    # User must confirm email before login
  end

  def create
    email = sign_up_params[:email]
    user = User.find_by(email: email)
    
    if user&.deleted?
      redirect_to new_user_restoration_path(email: email)
      return
    end
    
    super
  end

  # Override update to track changes
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    
    # Handle notification settings
    if params[:user][:notification_settings].present?
      settings = params[:user][:notification_settings].permit!.to_h
      
      # Handle expiring_days_before conversion
      if settings['expiring_days_before'].present?
        settings['expiring_days_before'] = settings['expiring_days_before'].split(',').map(&:strip).map(&:to_i)
      end
      
      settings.each do |key, value|
        next if key == 'expiring_days_before'
        settings[key] = (value == '1')
      end
      
      params[:user][:notification_settings] = settings
    end
    
    # Track what's being changed
    changed_fields = []
    is_password_change = params[:user][:password].present?
    
    # Detect profile changes
    %w[name english_name email company_name phone country address].each do |field|
      if params[:user][field.to_sym].present? && params[:user][field.to_sym] != resource.send(field)
        changed_fields << field
      end
    end

    prev_attributes = resource.attributes.slice('name', 'english_name', 'email', 'company_name', 'phone', 'country', 'address')
    
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

  # Override destroy to implement soft delete
  def destroy
    @user = current_user
    
    # Verify password before deletion
    unless @user.valid_password?(params[:user][:current_password])
      redirect_to delete_user_registration_path, alert: "비밀번호가 일치하지 않습니다."
      return
    end
    
    # Soft delete: set deleted_at and ban status
    if @user.update(deleted_at: Time.current, status: :banned)
      # Log account deletion
      AuditLogger.log(
        @user,
        @user,
        'soft_delete',
        "계정 삭제 (Soft Delete)",
        { deleted_at: Time.current },
        request.remote_ip
      )
      
      # Sign out the user
      sign_out(@user)
      
      redirect_to root_path, notice: "계정이 삭제되었습니다. 그동안 이용해 주셔서 감사합니다."
    else
      redirect_to delete_user_registration_path, alert: "계정 삭제에 실패했습니다."
    end
  end

  protected

  # Redirect to login page after signup with confirmation message
  def after_inactive_sign_up_path_for(resource)
    new_session_path(resource_name)
  end

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
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :english_name, :company_name, :phone, :country, :address, :email, :password, :password_confirmation, :terms])
  end

  # Devise 허용할 파라미터 설정 – 계정 수정
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name, :english_name, :company_name, :phone, :country, :address,
      :email, :password, :password_confirmation, :current_password,
      notification_settings: {}
    ])
  end
end
      