Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"
  
  scope module: :home do
    get :sign_in
  end

  mount ActionCable.server => '/websocket'
end
