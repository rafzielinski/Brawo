BrawoCms::Engine.routes.draw do
  namespace :admin do
    root to: "dashboard#index"
    resources :contents
    resources :taxonomies
  end
end

