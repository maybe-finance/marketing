# Below are the routes for madmin
namespace :madmin do
  resources :articles
  root to: "dashboard#show"
end
