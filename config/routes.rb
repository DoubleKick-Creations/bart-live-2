Rails.application.routes.draw do
  resources :stations, only: [:index]
  resources :stations, path: 'station/:time_format', only: [:show, :destroy]

  # resources :users ,only: [:create, :update, :destroy]
  # resources :reminders, only: [:index, :create, :destroy]
  # resources :closest_stations, only: [:create]
  # resource :sessions, only: [:new, :create, :destroy]
  
  root to: "stations#index"
end
