DreamforceUsers::Application.routes.draw do
  resources :users, :only => [:index, :new, :create]
  root :to => "users#index"
end
