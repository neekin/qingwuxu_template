Rails.application.routes.draw do

  # 前台（Turbo 演示）
  root "welcome#index"
  get "welcome/clock", to: "welcome#clock", as: :clock
  post "welcome/messages", to: "welcome#messages", as: :messages
  # 框架说明页（结构 / 使用说明 / 代码生成器蓝图），随框架演进同步维护
  get "docs", to: "docs#index", as: :docs

  # 后台登录（走 admin 命名空间 → Inertia/React 栈，与前台 Tailwind/Stimulus 隔离）
  # 先不管验权：create 为演示重定向，四期回填 ActionPolicy 真实校验。
  namespace :admin do
    root 'pages#dashboard'
    get 'dashboard', to: 'pages#dashboard'
    # 用户管理（真实 REST，含 POST/PUT/DELETE 写路径）
    resources :users, only: [:index, :create, :update, :destroy]
    # 角色管理（真实 REST，含 POST/PUT/DELETE 写路径）
    resources :roles, only: [:index, :create, :update, :destroy]
    get 'menus', to: 'pages#menus'
    get 'profile', to: 'pages#profile'
    # 操作日志 / 登录日志（只读审计视图；记录分别由 BaseController 自动写入 / SessionsController 登录时写入）
    resources :operation_logs, only: [:index]
    resources :login_logs, only: [:index]
    get 'inertia-example', to: 'inertia_example#index'
    # 字典管理（真实 REST，含 POST/PUT/DELETE 写路径）
    resources :dictionary_types, only: [:index, :create, :update, :destroy]
    resources :dictionary_data, only: [:index, :create, :update, :destroy]
    # 部门管理（真实 REST，含 POST/PUT/DELETE 写路径）
    resources :departments, only: [:index, :create, :update, :destroy]
    # 在线用户（监控视图：列出在线会话 + 强制下线）
    resources :online_users, only: [:index, :destroy]
    # Solid Queue 任务监控（只读）
    resources :solid_queue_jobs, only: [:index]
    # 系统监控看板（只读总览：Solid 三件套 + 应用指标）
    get "system_monitor", to: "system_monitor#index"
    # 文件管理（P1-D：本地磁盘 Active Storage）：列表 / 上传 / 删除
    resources :files, only: [:index, :create, :destroy]
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
