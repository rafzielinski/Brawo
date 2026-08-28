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
        custom_fields = (options[:fields] || []) + (options[:header_fields] || [])
        define_field_accessors(custom_fields) if custom_fields.present?

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

