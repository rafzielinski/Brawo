module BrawoCms
  module ContentTypeable
    extend ActiveSupport::Concern

    included do
      # Automatically inherit from BrawoCms::Content
      self.table_name = 'brawo_cms_contents'
    end

    class_methods do
      def content_type(name, options = {})
        @content_type_name = name
        @content_type_options = options

        # Register with BrawoCms
        BrawoCms.register_content_type(name, self, options)

        # Define field accessors
        if options[:fields].present?
          define_field_accessors(options[:fields])
        end

        # Set default scope to filter by type
        default_scope { where(type: self.name) }
      end

      def content_type_name
        @content_type_name
      end

      def content_type_options
        @content_type_options || {}
      end
    end
  end
end

