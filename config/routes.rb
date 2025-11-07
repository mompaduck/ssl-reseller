Rails.application.routes.draw do

  # 기본 헬스체크
  get "up" => "rails/health#show", as: :rails_health_check

  # ✅ 메인 페이지
  root "home#index"

  # 기본 페이지 예시
  get "about", to: "home#about", as: :about
  get "docs", to: "home#docs", as: :docs
  get "support", to: "home#support", as: :support
  get "contact", to: "home#contact", as: :contact


  # 인증 시스템 (Devise 사용)
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
}

  # 리소스 라우팅
  resources :products, only: [:index, :show]
  resources :orders, only: [:new, :create, :show]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  
end
