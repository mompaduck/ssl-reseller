if Rails.env.production?
  Rails.application.config.session_store :cookie_store,
    key: "_ssl_reseller_session",
    same_site: :none,
    secure: true
else
  Rails.application.config.session_store :cookie_store,
    key: "_ssl_reseller_session",
    same_site: :lax
end