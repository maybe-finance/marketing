Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :signups, only: [ :new, :create ]
  resources :articles, only: [ :index, :show ]
  resources :terms, only: [ :index, :show ], path: "financial-terms"

  get "tos" => "pages#tos"
  get "privacy" => "pages#privacy"

  get "sitemap", to: "pages#sitemap", defaults: { format: "xml" }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "pages#index"
end
