class Users::PasswordsController < Devise::PasswordsController
  # GET /users/password/new
  # def new
  #   super
  # end

  # POST /users/password
  # def create
  #   super
  # end

  # GET /users/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /users/password
  # def update
  #   super
  # end

  protected

  # 비밀번호 재설정 이메일 발송 후 리다이렉트 경로
  def after_sending_reset_password_instructions_path_for(resource_name)
    new_session_path(resource_name)
  end

  # 비밀번호 재설정 완료 후 리다이렉트 경로
  def after_resetting_password_path_for(resource)
    new_session_path(resource_name)
  end
end
