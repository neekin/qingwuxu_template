Rails.application.routes.draw do

  # 前台（Turbo 演示）
  root "welcome#index"
  get "welcome/clock", to: "welcome#clock", as: :clock
  post "welcome/messages", to: "welcome#messages", as: :messages

  # 后台登录（走 admin 命名空间 → Inertia/React 栈，与前台 Tailwind/Stimulus 隔离）
  # 先不管验权：create 为演示重定向，四期回填 ActionPolicy 真实校验。
  namespace :admin do
    root 'pages#dashboard'
    get 'dashboard', to: 'pages#dashboard'
    get 'users', to: 'pages#users'
    get 'roles', to: 'pages#roles'
    get 'menus', to: 'pages#menus'
    get 'departments', to: 'pages#departments'
    get 'operation-logs', to: 'pages#operation_logs'
    get 'login-logs', to: 'pages#login_logs'
    get 'profile', to: 'pages#profile'
    get 'inertia-example', to: 'inertia_example#index'
    get 'login', to: 'sessions#new', as: :login
    post 'login', to: 'sessions#create'
    post 'login/send_code', to: 'sessions#send_code', as: :login_send_code
    get 'register', to: 'sessions#register_page', as: :register
    post 'register', to: 'sessions#register'
  end
  
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
