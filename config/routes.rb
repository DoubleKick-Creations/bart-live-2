Rails.application.routes.draw do
  resources :stations, only: [:index]
  resources :stations, path: 'station/:time', only: [:show, :destroy]
  get '/stations/:id/remove', to: 'stations#remove', as: "remove_station"

  # resources :users ,only: [:create, :update, :destroy]
  # resources :reminders, only: [:index, :create, :destroy]
  # resources :closest_stations, only: [:create]
  # resource :sessions, only: [:new, :create, :destroy]
  
  root to: "stations#index"
end
