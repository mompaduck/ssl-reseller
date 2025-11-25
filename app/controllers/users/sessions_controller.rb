# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    super do |resource|
      # Log admin logins
      if resource.can_access_admin?
        AuditLogger.log(
          resource,
          resource,
          'login',
          "관리자 로그인 (#{resource.role})",
          { role: resource.role },
          request.remote_ip
        )
      end
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # 로그인 후 리다이렉트
  def after_sign_in_path_for(resource)
    if resource.can_access_admin?
      admin_root_path
    else
      root_path
    end
  end

  # 로그아웃 후 리다이렉트
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end