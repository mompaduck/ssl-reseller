Rails.application.routes.draw do

  # 기본 헬스체크
  get "up" => "rails/health#show", as: :rails_health_check

  # ✅ 메인 페이지
  root "home#index"

  # 기본 페이지 예시
  get "about",   to: "home#about",   as: :about
  get "docs",    to: "home#docs",    as: :docs
  get "support", to: "home#support", as: :support
  get "contact", to: "home#contact", as: :contact

   # 마이페이지
  get "my", to: "users#dashboard", as: :my_dashboard
  # 혹은 /my/settings 등 세부 페이지도 추가 가능
  get "my/orders", to: "users#orders", as: :my_orders

  # ✅ Devise 라우트
  devise_for :users, controllers: {
    sessions:       "users/sessions",
    registrations:  "users/registrations",
    #confirmations:  "users/confirmations"
  }

  # ✅ 이메일 중복 확인 (Devise scope 안에!)
  devise_scope :user do
    get "users/check_email", to: "users/registrations#check_email"
  end

  # 리소스 라우팅 (필요 시 주석 해제) 
   resources :orders,   only: [:new, :create, :show]
   resources :products, only: [:index, :show]
   resources :certificates, only: [:index]

end