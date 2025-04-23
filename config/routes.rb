require "sidekiq/web"

Rails.application.routes.draw do
  revise_auth

  authenticated -> { _1.admin? } do
    mount Sidekiq::Web => "/sidekiq"
    mount Avo::Engine, at: Avo.configuration.root_path
  end

  # Old redirects
  get "/tools/freedom-calculator", to: redirect("/tools/financial-freedom-calculator", status: 301)
  get "/tools/fomo-calculator", to: redirect("/tools", status: 301)
  get "/tools/crypto-index-fund", to: redirect("/tools", status: 301)
  get "/tools/low-hanging-fruit-checklist", to: redirect("/tools", status: 301)
  get "/tools/vote", to: redirect("/tools", status: 301)
  get "/ai", to: redirect("/features/assistant", status: 301)
  get "/ask", to: redirect("/", status: 301)
  get "/roadmap", to: redirect("/", status: 301)
  get "/podcast", to: redirect("/", status: 301)
  get "/now-subscribe", to: redirect("/", status: 301)
  get "/community", to: redirect("https://link.maybe.co/discord", status: 301)
  get "/early-access", to: redirect("https://app.maybefinance.com/early-access", status: 301)


  get "pricing", to: "pages#pricing"
  get "features/assistant/:category", to: "features#assistant", as: "assistant_category"
  get "features/assistant/:category/content", to: "features#assistant_content", as: "assistant_content"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :signups, only: [ :new, :create ]
  resources :articles, only: [ :index, :show ]
  resources :terms, only: [ :index, :show ], path: "financial-terms"
  resources :tools, only: [ :index, :show ], param: :slug do
    member do
      # Exchange rate calculator routes
      get ":from_currency/:to_currency(/:amount)",
        constraints: {
          from_currency: /[A-Z]{3}/,
          to_currency: /[A-Z]{3}/,
          amount: /\d+(\.\d+)?/
        },
        action: :show

      # Insider trading views
      get ":filter",
        action: :show,
        constraints: {
          filter: /top-owners|biggest-trades|top-officers/,
          slug: "inside-trading-tracker"
        }

      # Stock symbol route
      get ":symbol", action: :show, constraints: { symbol: /[A-Z]+/ }
    end
  end

  resources :features, only: [] do
    collection do
      get "tracking"
      get "transactions"
      get "budgeting"
      get "assistant"
    end
  end

  get "stocks/exchanges/:id", to: "stocks#exchanges", as: :stock_exchange
  get "stocks/sectors/:id", to: "stocks#sectors", as: :stock_sector
  get "stocks/industries/:id", to: "stocks#industries", as: :stock_industry

  resources :stocks, only: [ :index ] do
    collection do
      get :all
      get :exchanges
      get :industries
      get :sectors
    end
  end

  resources :stocks, only: [ :show ], param: :ticker, constraints: { ticker: /[^\/]+/ } do
    scope module: :stocks do
      resource :info, only: :show, controller: "info"
      resource :statistics, only: :show
      resource :news, only: :show
      resource :chart, only: :show, controller: "chart"
      resource :price_performance, only: :show, controller: "price_performance"
      resource :similar_stocks, only: :show, controller: "similar_stocks"
    end
  end

  resources :stocks do
    member do
      post "cache_page", as: :cache
    end
  end

  get "tos" => "pages#tos"
  get "terms", to: redirect("/tos", status: 301)
  get "privacy" => "pages#privacy"

  get "sitemap.xml", to: "pages#sitemap_index", defaults: { format: "xml" }
  get "sitemap_:page.xml", to: "pages#sitemap", defaults: { format: "xml" }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "pages#index"
end
