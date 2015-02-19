Rails.application.routes.draw do
  root 'games#show'

  devise_for :users
  resource :games
end
