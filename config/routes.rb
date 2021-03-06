Rails.application.routes.draw do
  devise_for :users, :controllers => {
    sessions:       'users/sessions',
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"

  get "trigger_error", to: "home#trigger_error"
  post "speak_to_robot", to: "home#speak_to_robot"

  get "auth/wechat/callback", to: "wx#oauth_callback"
  get "auth/failure", to: "wx#oauth_failure"

  namespace :weixin do
    get :test_weixin
    get :current_status
    post :start_recording
    post :stop_recording
  end

  namespace :wx do
    post :notify
  end

  namespace :shop do
    get :index
    get :wholesale
    get :wholesale_instances
  end

  namespace :addresses do
    post :destroy
    post :create
    post :update
  end

  resources :history_logs, only: [:create]

  resources :orders, only: [:index, :show, :create]
  resources :wholesale_orders, only: [:index, :show, :create]

  resources :articles do
    resources :comments, only: [:create]
  end

  namespace :admin do
    root "orders#index"
    resources :orders, only: [:index, :show, :update, :edit] do
      member do
        post :next_state
        post :abandon
        get :invoice
      end

      collection do
        post :bulk_push
        get :bulk_ingredient
        get :bulk_export_csv
      end
    end

    resources :wholesale_orders, only: [:index, :show, :update, :edit] do
      member do
        post :next_state
        post :abandon
        get :invoice
      end

      collection do
        get :bulk_export_csv
        post :bulk_push
      end
    end

    resources :ingredients, only: [:index, :edit, :update]
  end
end
