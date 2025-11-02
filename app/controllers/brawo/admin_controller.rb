module Brawo
  class AdminController < ApplicationController
    layout 'brawo/admin'
    before_action :authenticate_user!
    
    private
    
    def authenticate_user!
      # Allow the host app to handle authentication
      # This can be overridden by the host app
      unless defined?(current_user) && current_user
        redirect_to main_app.root_path, alert: "Please sign in to access the admin area"
      end
    end
  end
end