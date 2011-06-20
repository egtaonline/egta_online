EgtaOnline::Application.routes.draw do
  devise_for :users
  resources :accounts
  root :to => 'application#index'
end
