EgtMongoid::Application.routes.draw do

  devise_for :users

  resources :pbs_generators
  resources :home
  resources :yaml
  resources :prep_work
  resources :accounts
  resources :simulators
  resources :game_schedulers
  resources :games do
    resources :profiles, :only => [:index, :show, :destroy]
    resources :game_schedulers
    resources :features
    resources :control_variates, :only => [:index, :show, :destroy, :new] do
      collection do
        post 'add_feature', 'remove_feature', 'update_choice'
      end
    end
    collection do
      post 'update_parameters'
    end
    member do
      get 'regret'
    end
    member do
      post 'add_strategy', 'remove_strategy'
    end
  end
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

