BrawoCms::Engine.routes.draw do
  if defined?(Rswag::Ui::Engine)
    mount Rswag::Ui::Engine => "/api/docs"
    mount Rswag::Api::Engine => "/api/docs"
  end

  namespace :api do
    namespace :v1 do
      resources :content_types, only: [:index, :show], param: :type
      resources :taxonomy_types, only: [:index, :show], param: :type
      resources :contents, only: [:index, :show, :create, :update, :destroy]
      resources :taxonomies, only: [:index, :show, :create, :update, :destroy]
    end
  end

  namespace :admin do
    root to: "dashboard#index"
    resources :contents do
      member do
        get :preview
      end
    end
    resources :taxonomies
  end
end
