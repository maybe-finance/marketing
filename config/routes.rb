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

  # Redirect for removed inside trading tracker
  get "/tools/inside-trading-tracker(/*path)", to: redirect("/", status: 301)

  get "pricing", to: "pages#pricing"
  get "about", to: "pages#about"
  get "features/assistant/:category", to: "features#assistant", as: "assistant_category"
  get "features/assistant/:category/content", to: "features#assistant_content", as: "assistant_content"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :signups, only: [ :new, :create ]
  resources :articles, only: [ :index, :show ]
  resources :terms, only: [ :index, :show ], path: "financial-terms"
  resources :faqs, only: [ :index, :show ], path: "financial-faqs"
  resources :authors, only: [ :index, :show ], param: :slug
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

  # Bank search routes
  get "/bank-search", to: "bank_search#index", as: :bank_search
  get "/api/bank-search", to: "bank_search#search", as: :bank_search_api

  # Specific route for stocks index with combobox param
  get "/stocks", to: "stocks#index", constraints: lambda { |req| req.params[:combobox].present? }, as: :stocks_combobox

  # Redirect all other /stocks... paths
  get "stocks(/*path)", to: redirect("/", status: 301)

  get "tos" => "pages#tos"
  get "terms", to: redirect("/tos", status: 301)
  get "privacy" => "pages#privacy"

  get "sitemap.xml", to: "pages#sitemap_index", defaults: { format: "xml" }
  get "sitemap_:page.xml", to: redirect("/sitemap.xml", status: 301)

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "pages#index"

  # Catch-all route for redirects (must be last)
  get "*path", to: "redirects#catch_all", constraints: lambda { |req| !req.path.start_with?("/rails/") }
end
