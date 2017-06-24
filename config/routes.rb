Rails.application.routes.draw do
  devise_for :users, :controllers => {
    sessions:       'users/sessions',
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"

  get "trigger_error", to: "home#trigger_error"

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
    root "orders#index"
    resources :orders, only: [:index, :show, :update] do
      member do
        post :next_state
        post :abandon
        get :invoice
      end

      collection do
        post :bulk_push
        get :bulk_invoice
        get :bulk_ingredient
      end
    end
  end
end
