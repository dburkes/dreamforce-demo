DreamforceUsers::Application.routes.draw do
  resources :users, :only => [:index, :new, :create]
  match "config_warning" => "application#config_warning"
  root :to => "users#index"
end
