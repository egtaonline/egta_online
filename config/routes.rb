EgtaOnline::Application.routes.draw do

  devise_for :users
  resources :accounts, :except => [:edit, :update]
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
  match "/application/prep_work" => "application#prep_work"
  root :to => 'application#index'
  authenticate :user do
    mount Resque::Server, :at => "/background_workers"
  end
end
