# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [:google_oauth2, :failure]

  def google_oauth2

Rails.logger.info "🔥 OAuth Callback Received"
  Rails.logger.info "🔸 request.original_url: #{request.original_url}"
  Rails.logger.info "🔸 forwarded proto: #{request.env['HTTP_X_FORWARDED_PROTO']}"
  Rails.logger.info "🔸 cookie: #{request.cookies.inspect}"


    # 디버깅 로그
    Rails.logger.info "=" * 60
    Rails.logger.info "OmniAuth Data: #{request.env['omniauth.auth'].inspect}"
    Rails.logger.info "=" * 60

    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = "Google 계정으로 로그인했습니다."
      sign_in_and_redirect @user, event: :authentication
    else
      Rails.logger.error "User save failed: #{@user.errors.full_messages}"
      session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  rescue StandardError => e
    Rails.logger.error "Google OAuth Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to root_path, alert: "Google 로그인 중 오류가 발생했습니다: #{e.message}"
  end

  def failure
    Rails.logger.error "OAuth Failure: #{params.inspect}"
    Rails.logger.error "Failure Message: #{request.env['omniauth.error']}"
    Rails.logger.error "Failure Type: #{request.env['omniauth.error.type']}"
    
    redirect_to root_path, alert: "Google 로그인에 실패했습니다."
  end
end