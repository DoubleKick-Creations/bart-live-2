# frozen_string_literal: true

Rails.application.routes.draw do
  resources :stations, only: [:index]
  resources :stations, path: 'station/:time_format', only: [:show]

  # resources :users ,only: [:create, :update, :destroy]
  # resources :reminders, only: [:index, :create, :destroy]
  # resources :closest_stations, only: [:create]
  # resource :sessions, only: [:new, :create, :destroy]

  root to: 'stations#index'
end
