# config/routes.rb
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
    # 이메일 중복 확인 API (POST → GET 변경)
    get 'users/check_email', to: 'users/registrations#check_email', as: :check_email_user_registration
    
    # 계정 삭제 페이지
    get 'users/delete', to: 'users/registrations#delete', as: :delete_user_registration
    
    # 회원탈퇴 완료 페이지
    get 'users/deleted', to: 'users/registrations#deleted', as: :deleted_user_registration
  end

  # 리소스 라우팅
  resources :orders, only: [:new, :create, :show]
  resources :products, only: [:index, :show]
  resources :certificates, only: [:index]
end