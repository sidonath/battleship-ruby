Rails.application.routes.draw do
  root 'users#show'

  devise_for :users
  resource :user, only: [:show, :update]

  namespace :admin do
    root 'users#index'
    resources :users
    resources :games, only: [:create, :show] do
      member do
        post :start
      end
    end
  end
end
