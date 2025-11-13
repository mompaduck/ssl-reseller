class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_google(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      flash[:notice] = "Google 계정으로 로그인했습니다."
    else
      redirect_to new_user_registration_url, alert: "Google 인증에 실패했습니다."
    end
  end

  def failure
    redirect_to root_path, alert: "Google 인증 오류가 발생했습니다."
  end
end