Brawo::Engine.routes.draw do
  namespace :admin do
    root to: 'dashboard#index'
    
    # Content entries routes for each content type
    get ':content_type_slug', to: 'content_entries#index', as: :content_entries
    get ':content_type_slug/new', to: 'content_entries#new', as: :new_content_entry
    post ':content_type_slug', to: 'content_entries#create'
    get ':content_type_slug/:id/edit', to: 'content_entries#edit', as: :edit_content_entry
    patch ':content_type_slug/:id', to: 'content_entries#update', as: :content_entry
    put ':content_type_slug/:id', to: 'content_entries#update'
    delete ':content_type_slug/:id', to: 'content_entries#destroy'
  end
  
  # Public content routes are registered automatically by RouteManager
end