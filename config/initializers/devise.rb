# frozen_string_literal: true

Devise.setup do |config|
  # OmniAuth 기본 설정
  OmniAuth.config.allowed_request_methods = [:get, :post]
  OmniAuth.config.full_host = ->(env) {
    scheme = env['HTTP_X_FORWARDED_PROTO'] || env['rack.url_scheme']
    host   = env['HTTP_X_FORWARDED_HOST'] || env['HTTP_HOST']
    "#{scheme}://#{host}"
  }

  # 🔥 여기 안에 있어야 한다!!
  config.omniauth :google_oauth2,
    ENV['GOOGLE_CLIENT_ID'],
    ENV['GOOGLE_CLIENT_SECRET'],
    {
      scope: 'email,profile',
      access_type: 'offline',
      prompt: 'consent',
      redirect_uri: 'https://certgate.duckdns.org/users/auth/google_oauth2/callback'
    }

  # Email
  config.mailer_sender = ENV['SMTP_USERNAME'] || 'no-reply@certgate.duckdns.org'

  # ORM
  require 'devise/orm/active_record'

  # Enable scoped views to use app/views/users/mailer instead of default Devise views
  config.scoped_views = true

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  
  # Confirmable settings - 이메일 인증 필수
  config.allow_unconfirmed_access_for = 0.days  # 인증 안 된 사용자는 로그인 불가
  config.confirm_within = 3.days  # 3일 이내에 인증해야 함
  config.reconfirmable = true  # 이메일 변경 시 재인증 필요
  
  config.sign_out_via = :delete

  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end