# Below are the routes for madmin
namespace :madmin do
  resources :terms
  resources :articles
  root to: "dashboard#show"
end
