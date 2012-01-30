EgtaOnline::Application.routes.draw do

  devise_for :users

  namespace :api do
    resources :schedulers do
      member do
        post :add_profile
      end
    end
  end

  resources :accounts
  resources :profiles, :only => :show
  match "/simulations/destroy" => "simulations#destroy"
  resources :simulations, :except => [:edit, :update]
  resources :schedulers, :game_schedulers, :hierarchical_schedulers do
    member do
      post :add_strategy, :remove_strategy, :add_role, :remove_role
    end
    collection do
      post :update_parameters
    end
  end
  resources :games do
    member do
      post :add_strategy, :remove_strategy, :add_role, :remove_role, :add_feature, :remove_feature
      get :show_with_samples
    end
    collection do
      post :update_parameters
      get :from_scheduler
    end
  end

  resources :simulators, :except => [:edit, :update] do
    member do
      post :add_strategy, :remove_strategy, :add_role, :remove_role
    end
  end
  
  root :to => 'high_voltage/pages#show', :id => 'home'
  authenticate :user do
    mount Resque::Server, :at => "/background_workers"
  end
end
