EgtaOnline::Application.routes.draw do

  resources :deviation_schedulers

  devise_for :users

  namespace :api do
    namespace :v3 do
      resources :generic_schedulers, :except => ["new", "edit"] do
        member do
          post :add_profile, :remove_profile, :add_role, :remove_role
        end
      end
      resources :simulators, :games, :only => [:show, :index] do
        member do
          post :add_strategy, :remove_strategy, :add_role, :remove_role
        end
      end
      resources :profiles, :only => :show
    end
  end

  resources :profiles, :only => :show
  resources :simulations, :only => [:index, :show]
  resources :schedulers do
    collection do
      post :update_configuration
    end
    member do
      get :page_profiles
      post :create_game_to_match
    end
  end
  resources :deviation_schedulers, :hierarchical_deviation_schedulers do
    member do
      post :add_strategy, :remove_strategy, :add_role, :remove_role, :add_deviating_strategy, :remove_deviating_strategy
    end
    collection do
      post :update_configuration
    end
  end
  
  resources :generic_schedulers do
    member do
      post :add_role, :remove_role
    end
    collection do
      post :update_configuration
    end
  end
  
  resources :game_schedulers, :hierarchical_schedulers do
    member do
      post :add_strategy, :remove_strategy, :add_role, :remove_role
    end
    collection do
      post :update_configuration
    end
  end
  
  resources :games do
    member do
      post :add_strategy, :remove_strategy, :add_role, :remove_role, :calculate_cv_coefficients
    end
    collection do
      post :update_configuration
    end
    resources :features, :only => [:create, :destroy]
  end

  resources :simulators do
    member do
      post :add_strategy, :remove_strategy, :add_role, :remove_role
    end
  end
  
  root :to => 'high_voltage/pages#show', :id => 'home'
  authenticate :user do
    mount Resque::Server, :at => "/background_workers"
  end
end
