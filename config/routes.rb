EgtMongoid::Application.routes.draw do

  devise_for :users

  resources :pbs_generators
  resources :home
  resources :yaml
  resources :prep_work
  resources :accounts
  resources :simulators do
    member do
      post 'add_strategy', 'remove_strategy'
    end
    resources :games do
      member do
        post 'add_strategy', 'remove_strategy'
      end
      resources :profiles, :only => [:index, :show, :destroy]
      resources :game_schedulers
      resources :features
      resources :control_variates, :only => [:index, :show, :destroy] do
        collection do
          post 'add_feature', 'remove_feature', 'update_choice'
        end
      end
      collection do
        post 'update_parameters'
      end
    end
  end
  resources :games do
    collection do
      post 'select_simulator'
    end
  end
  resources :game_schedulers
    resources :feature_samples
    resources :simulations, :only => [:index, :show] do
      resources :samples
      collection do
        get 'purge'
        post 'update_game'
      end
    end
  resources :features
  resources :profile_schedulers
  resources :deviation_schedulers
  resources :pbs_generators
  root :to => 'home#index'

end

