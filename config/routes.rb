EgtaOnline::Application.routes.draw do

  devise_for :users
  resources :accounts
  resources :analysis
  resources :profiles, :only => :show
  match "/simulations/destroy" => "simulations#destroy"
  resources :simulations, :except => [:edit, :update]
  resources :schedulers, :symmetric_game_schedulers, :games do
    member do
      post :add_strategy, :remove_strategy
    end
    collection do
      post :update_parameters
    end
  end
  resources :simulators, :except => [:edit, :update] do
    member do
      post :add_strategy, :remove_strategy
    end
  end
  root :to => 'application#index'
end
