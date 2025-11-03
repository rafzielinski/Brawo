module BrawoCms
  module TaxonomyTypeable
    extend ActiveSupport::Concern

    included do
      # Automatically inherit from BrawoCms::Taxonomy
      self.table_name = 'brawo_cms_taxonomies'
    end

    class_methods do
      def taxonomy_type(name, options = {})
        @taxonomy_type_name = name
        @taxonomy_type_options = options

        # Register with BrawoCms
        BrawoCms.register_taxonomy_type(name, self, options)

        # Define field accessors
        if options[:fields].present?
          define_field_accessors(options[:fields])
        end

        # Set default scope to filter by type
        default_scope { where(type: self.name) }
      end

      def taxonomy_type_name
        @taxonomy_type_name
      end

      def taxonomy_type_options
        @taxonomy_type_options || {}
      end
    end
  end
end

