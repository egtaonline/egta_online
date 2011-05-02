EgtMongoid::Application.routes.draw do

  resources :instructions

  devise_for :users

  resources :schedulers
  resources :game_manipulations
  resources :accounts
  resources :simulators do
    member do
      post 'add_strategy', 'remove_strategy'
    end
  end

  resources :games do
    resources :profiles, :only => [:index, :show, :destroy]
    resources :features
    resources :control_variates, :exclude => [:index] do
      collection do
        post 'add_feature', 'remove_feature', 'update_choice'
      end
    end
    collection do
      post 'update_parameters'
    end
    member do
      get 'regret', 'robust_regret', 'analysis', 'rd'
    end
    member do
      post 'add_strategy', 'remove_strategy'
    end
    collection do
      post 'update_parameters', 'select_simulator'
    end
  end
  resources :simulations, :only => [:index, :show] do
    collection do
      get 'update_game'
      post 'purge'
    end
  end
  resources :game_schedulers
  resources :profile_schedulers
  resources :deviation_schedulers
  root :to => 'home#index'
  match "/home/prep_work" => 'home#prep_work'

end

