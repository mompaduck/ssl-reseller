# config/initializers/session_store.rb

if Rails.env.production?
  Rails.application.config.session_store :cookie_store,
    key: '_ssl_reseller_session',
    domain: 'certgate.duckdns.org',
    secure: true,
    same_site: :none
else
  # 개발에서는 기존 기본 설정 유지
  Rails.application.config.session_store :cookie_store,
    key: '_ssl_reseller_session'
end