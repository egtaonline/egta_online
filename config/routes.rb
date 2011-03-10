EgtMongoid::Application.routes.draw do

  devise_for :users

  resources :accounts
  resources :simulators do
    member do
      post 'add_strategy', 'remove_strategy'
    end
  end
      #   resources :control_variates, :only => [:index, :show, :destroy] do
      #   collection do
      #     post 'add_feature', 'remove_feature', 'update_choice'
      #   end
      # end
  resources :games do
    resources :profiles, :only => [:index, :show, :destroy]
    resources :features
    member do
      post 'add_strategy', 'remove_strategy'
    end
    collection do
      post 'update_parameters', 'select_simulator'
    end
  end
  resources :simulations, :only => [:index, :show] do
    collection do
      get 'purge'
      post 'update_game'
    end
  end
  resources :game_schedulers
  resources :profile_schedulers
  resources :deviation_schedulers
  resources :pbs_generators
  root :to => 'home#index'
  match "/home/prep_work" => 'home#prep_work'

end

