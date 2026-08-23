Rails.application.routes.draw do
  mount BrawoCms::Engine => "/admin"

  root "pages#home"

  # brawo_cms:routes
  resources :articles, only: %i[index show], param: :slug
  resources :products, only: %i[index show], param: :slug

  BrawoCms::Routing.draw_root_route(self)
end
