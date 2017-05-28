Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "shop#index"

  get "auth/wechat/callback", to: "wx#oauth_callback"

  namespace :shop do

  end

  namespace :addresses do
    post :destroy
    post :create
    post :update
  end

  namespace :orders do
    post :create
  end
end
