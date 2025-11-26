class Users::RestorationsController < ApplicationController
  skip_before_action :authenticate_user!
  
  def new
    @email = params[:email]
  end

  def create
    user = User.find_by(email: params[:user][:email])
    
    if user&.deleted?
      # Generate token for restoration (using reset_password_token mechanism)
      raw, enc = Devise.token_generator.generate(User, :reset_password_token)
      user.reset_password_token = enc
      user.reset_password_sent_at = Time.now.utc
      user.save(validate: false)
      
      # Send restoration email
      UserMailer.restore_account(user, raw).deliver_later
      
      redirect_to new_user_session_path, notice: "계정 복구 인증 메일이 발송되었습니다. 메일을 확인해주세요."
    else
      redirect_to new_user_registration_path, alert: "복구할 계정을 찾을 수 없습니다."
    end
  end

  def update
    original_token = params[:token]
    reset_password_token = Devise.token_generator.digest(User, :reset_password_token, original_token)
    
    user = User.find_by(reset_password_token: reset_password_token)
    
    if user && user.reset_password_period_valid?
      user.update(deleted_at: nil, status: :active, reset_password_token: nil, reset_password_sent_at: nil)
      
      # Log restoration
      AuditLogger.log(
        user,
        user,
        'activate',
        "계정 복구 (Restoration)",
        {},
        request.remote_ip
      )
      
      sign_in(user)
      redirect_to root_path, notice: "계정이 성공적으로 복구되었습니다. 환영합니다!"
    else
      redirect_to new_user_session_path, alert: "복구 링크가 유효하지 않거나 만료되었습니다."
    end
  end
end
