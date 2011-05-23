EgtMongoid::Application.routes.draw do

  #indexers
  devise_for :users
  resources :accounts
  resources :profiles
  resources :simulations, :except => :edit
  resources :game_schedulers
  resources :simulators, :games, :except => :edit do
    member do
      post :add_strategy, :remove_strategy
    end
  end
  match "/simulations/destroy" => "simulations#destroy"
  match "/games/new/update_parameters" => "games#update_parameters"
  root :to => 'home#index'
end

