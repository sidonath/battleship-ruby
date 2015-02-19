Rails.application.routes.draw do
  root 'users#show'

  devise_for :users
  resource :user, only: [:show, :update]

  namespace :admin do
    root 'users#index'
    resources :users
  end
end
