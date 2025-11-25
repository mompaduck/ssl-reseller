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
  devise_for :users, 
    controllers: {
      sessions: "users/sessions",
      registrations: "users/registrations",
      passwords: "users/passwords",
      confirmations: "users/confirmations",
      omniauth_callbacks: "users/omniauth_callbacks"
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

    # 이메일 인증
     get "/confirm/:token", to: "users#confirm", as: :confirm_user
   end

  # 사용자 대시보드
  get 'dashboard', to: 'users#dashboard', as: :dashboard

  # 리소스 라우팅
  get 'my_orders', to: 'orders#my_orders', as: :my_orders
  
  resources :orders, only: [:new, :create, :show, :index] do
    post 'pay', on: :member
  end
  resources :products, only: [:index, :show]
  resources :certificates, only: [:index]

  # 관리자 페이지
  namespace :admin do
    root "dashboard#index"
    resources :orders, only: [:index, :show] do
      member do
        patch :update_status
      end
    end
    resources :certificates, only: [:index, :show] do
      member do
        # Tab actions for Turbo Frames
        get :overview
        get :dcv
        get :files
        get :issue_logs
        get :audit_logs
        get :billing
        get :customer
        
        # Certificate actions
        get :download
        post :reissue
        post :cancel
        post :resend_dcv
        post :refresh_status
        post :send_reminder
        post :refresh_dcv
        post :change_dcv_method
        get :download_dcv_file
        post :force_issue
      end
    end
    
    # Log routes
    resources :audit_logs, only: [:index]
    resources :order_logs, only: [:index]
    resources :certificate_logs, only: [:index]
    resources :api_logs, only: [:index]
    resources :notification_logs, only: [:index]
    resources :system_logs, only: [:index]
    
    # Settings routes
    scope :settings, module: 'settings' do
      get :logging_retention, to: 'logging_retention#logging_retention', as: :settings_logging_retention
      patch :logging_retention, to: 'logging_retention#update_logging_retention', as: :settings_update_logging_retention
      
      get :email_smtp, to: 'email_smtp#email_smtp', as: :settings_email_smtp
      patch :email_smtp, to: 'email_smtp#update_email_smtp', as: :settings_update_email_smtp
      post :test_email, to: 'email_smtp#test_email', as: :settings_test_email
    end
    
    resources :users do
      member do
        patch :update_role
        patch :assign_partner
        patch :suspend
        patch :activate
        delete :soft_delete
        post :reset_password
        post :confirm_email
        post :unconfirm_email
      end
    end
  end
end