Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"

  get "auth/wechat/callback", to: "wx#oauth_callback"
  get "auth/failure", to: "wx#oauth_failure"

  namespace :wx do
    post :notify
  end

  namespace :shop do
    get :index
  end

  namespace :addresses do
    post :destroy
    post :create
    post :update
  end

  resources :orders, only: [:index, :show, :create]

  namespace :admin do
    resources :orders, only: [:index, :show]
  end
end
