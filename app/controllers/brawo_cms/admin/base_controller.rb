module BrawoCms
  module Admin
    class BaseController < ActionController::Base
      layout 'brawo_cms/admin/application'

      before_action :set_content_types
      before_action :set_taxonomy_types

      private

      def set_content_types
        @content_types = BrawoCms.content_types
      end

      def set_taxonomy_types
        @taxonomy_types = BrawoCms.taxonomy_types
      end
    end
  end
end

