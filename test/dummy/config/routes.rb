Rails.application.routes.draw do
  mount BrawoCms::Engine => "/admin"
  
  root "pages#home"
  
  # Example routes for viewing content
  resources :articles, only: [:index, :show]
  resources :products, only: [:index, :show]
end

