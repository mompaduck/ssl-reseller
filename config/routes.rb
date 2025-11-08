Rails.application.routes.draw do
  # 기본 헬스체크
  get "up" => "rails/health#show", as: :rails_health_check

  # 메인 페이지
  root "home#index"

  # 일반 페이지
  get "about", to: "home#about", as: :about
  get "docs", to: "home#docs", as: :docs
  get "support", to: "home#support", as: :support
  get "contact", to: "home#contact", as: :contact

  # 인증 시스템 (Devise 사용)
  devise_for :users, controllers: {
    sessions:      "users/sessions",
    registrations: "users/registrations",
    confirmations: "users/confirmations"
  }

  devise_scope :user do
    # 회원탈퇴 완료 페이지
    get 'users/deleted', to: 'users/registrations#deleted', as: :deleted_user_registration
    # 이메일 중복 확인 API
    get 'users/check_email', to: 'users/registrations#check_email'
  end

  # 기타 리소스 라우트들…
 # 리소스 라우팅 (필요 시 주석 해제) 
   resources :orders,   only: [:new, :create, :show]
   resources :products, only: [:index, :show]
   resources :certificates, only: [:index]

end


 
