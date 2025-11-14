# config/routes.rb
Rails.application.routes.draw do
  # get "products/index"
  # get "products/show"
  # 기본 헬스체크
  get "up" => "rails/health#show", as: :rails_health_check

  # 메인 페이지
  root "home#index"

  # 일반 페이지
  get "about", to: "home#about", as: :about
  get "docs", to: "home#docs", as: :docs
  get "support", to: "home#support", as: :support
  get "contact", to: "home#contact", as: :contact
  get "pricing", to: "pricing#index", as: :pricing

  # FAQ
  get 'faq', to: 'pages#faq', as: 'faq'


  # 인증 시스템 (Devise 사용)
  devise_for :users, controllers: {
    sessions:      "users/sessions",
    registrations: "users/registrations",
    confirmations: 'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks'  # 추가
  }

  devise_scope :user do
    # 이메일 중복 확인 API (POST → GET 변경)
    get 'users/check_email', to: 'users/registrations#check_email', as: :check_email_user_registration
    
    # 계정 삭제 페이지
    get 'users/delete', to: 'users/registrations#delete', as: :delete_user_registration
    
    # 회원탈퇴 완료 페이지
    get 'users/deleted', to: 'users/registrations#deleted', as: :deleted_user_registration


    #Devise failure 처리
    get '/users/auth/failure', to: 'users/sessions#new'
  end

  # 리소스 라우팅
  resources :orders, only: [:new, :create, :show]
  resources :products, only: [:index, :show]
  resources :certificates, only: [:index]
end