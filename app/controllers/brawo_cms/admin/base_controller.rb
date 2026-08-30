module BrawoCms
  module Admin
    class BaseController < ActionController::Base
      layout 'brawo_cms/admin/application'

      helper BrawoCms::Admin::ApplicationHelper

      before_action :require_admin_authentication
      before_action :set_content_types
      before_action :set_taxonomy_types

      private

      def require_admin_authentication
        rodauth.require_authentication
        return if Rails.env.test?

        rodauth.require_two_factor_setup
        rodauth.require_two_factor_authenticated
      end

      def current_account
        rodauth.rails_account
      end
      helper_method :current_account

      def set_content_types
        @content_types = BrawoCms.content_types
      end

      def set_taxonomy_types
        @taxonomy_types = BrawoCms.taxonomy_types
      end
    end
  end
end

