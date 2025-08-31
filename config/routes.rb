Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "cores#index"

  # 添加修改密码路由
  namespace :admin do
    get 'change_password', to: 'passwords#edit', as: 'edit_password'
    put 'update_password', to: 'passwords#update', as: 'update_password'
  end
  
  # 健康检查端点
  get '/health', to: proc { [200, {}, ['OK']] }
end
