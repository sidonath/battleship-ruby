Rails.application.routes.draw do
  root 'games#show'

  devise_for :users
  resource :games

  namespace :admin do
    root 'users#index'
    resources :users
  end
end
