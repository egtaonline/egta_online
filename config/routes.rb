EgtaOnline::Application.routes.draw do

  devise_for :users
  resources :accounts
  resources :profiles, :only => :show
  resources :simulations, :except => [:edit, :update] do
    collection do
      post :purge
    end
  end
  resources :schedulers do
    member do
      post :add_strategy, :remove_strategy
    end
    collection do
      post :update_parameters
    end
  end
  resources :symmetric_game_schedulers do
    member do
      post :add_strategy, :remove_strategy
    end
  end
  resources :simulators, :except => [:edit, :update] do
    member do
      post :add_strategy, :remove_strategy
    end
  end
  match "/profiles/:id" => "profiles#show"
  root :to => 'application#index'
end
