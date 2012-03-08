EgtaOnline::Application.routes.draw do

  devise_for :users

  namespace :api do
    resources :schedulers, :except => ["new", "edit"] do
      member do
        post :add_profile
      end
      collection do
        get :find
      end
    end
  end

  resources :accounts
  resources :profiles, :only => :show
  resources :simulations, :only => [:index, :show]
  resources :schedulers do
    collection do
      post :update_parameters
    end
    member do
      get :page_profiles
    end
  end
  resources :game_schedulers, :hierarchical_schedulers do
    member do
      post :add_strategy, :remove_strategy, :add_role, :remove_role
    end
    collection do
      post :update_parameters
    end
  end
  resources :games, :except => [:edit, :update] do
    member do
      post :add_strategy, :remove_strategy, :add_role, :remove_role
      get :show_with_samples
    end
    collection do
      post :update_parameters
      get :from_scheduler
    end
    resources :features, :only => [:create, :destroy]
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
