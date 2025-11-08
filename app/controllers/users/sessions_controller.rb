# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  layout 'application'

  def after_sign_in_path_for(resource)
    flash[:notice] = "🎉 CertGate에 오신 걸 환영합니다!"
    root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end