Rails.application.routes.draw do
  namespace :stocks do
    get "news/show"
    get "info/show"
  end
  revise_auth

  authenticated -> { _1.admin? } do
    mount Avo::Engine, at: Avo.configuration.root_path
  end

  # Old redirects
  get "/tools/freedom-calculator", to: redirect("/tools/financial-freedom-calculator", status: 301)

  get "/tools/crypto-index-fund", to: redirect("/tools", status: 302)
  get "/tools/low-hanging-fruit-checklist", to: redirect("/tools", status: 302)
  get "/tools/compound-interest-calculator", to: redirect("/tools", status: 302)

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :signups, only: [ :new, :create ]
  resources :articles, only: [ :index, :show ]
  resources :terms, only: [ :index, :show ], path: "financial-terms"
  resources :tools, only: [ :index, :show ]

  resources :stocks, only: [ :index ]
  resources :stocks, only: :show, param: :ticker do
    scope module: :stocks do
      # 1 Day cache
      resource :info, only: :show, controller: "info"
      resource :statistics, only: :show
      resource :news, only: :show
    end
  end

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
