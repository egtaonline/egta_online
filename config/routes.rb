EgtMongoid::Application.routes.draw do

  #indexers
  devise_for :users

  resources :schedulers, :only => [:index]
  resources :game_manipulations, :only => [:index]
  resources :game_schedulers, :exclude => [:index]
  resources :accounts
  resources :simulators do
    member do
      post 'add_strategy', 'remove_strategy'
    end
  end

  resources :games do
    resources :profiles, :only => [:index, :show]
    resources :features
    resources :game_schedulers, :exclude => [:index]
    resources :control_variates, :exclude => [:index] do
      collection do
        post 'add_feature', 'remove_feature', 'update_choice'
      end
    end
    member do
      get 'regret', 'robust_regret', 'analysis', 'rd'
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
  root :to => 'home#index'
  match "home/prep_work" => "home#prep_work"
end

