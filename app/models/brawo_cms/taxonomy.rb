module BrawoCms
  class Taxonomy < ActiveRecord::Base
    self.table_name = 'brawo_cms_taxonomies'

    # Validations
    validates :name, presence: true
    validates :slug, presence: true, uniqueness: true

    # Callbacks
    before_validation :generate_slug, if: -> { slug.blank? && name.present? }

    # Field accessor methods
    def get_field(key)
      fields[key.to_s]
    end

    def set_field(key, value)
      self.fields = fields.merge(key.to_s => value)
    end

    def field_value(key)
      get_field(key)
    end

    # Dynamic field methods based on taxonomy type definition
    def self.define_field_accessors(field_definitions)
      field_definitions.each do |field_def|
        field_name = field_def[:name]
        
        define_method(field_name) do
          get_field(field_name)
        end

        define_method("#{field_name}=") do |value|
          set_field(field_name, value)
        end
      end
    end

    # Taxonomy type metadata
    def taxonomy_type_name
      self.class.name.demodulize.underscore
    end

    def taxonomy_type_config
      BrawoCms.taxonomy_types[taxonomy_type_name.to_sym]
    end

    def field_definitions
      taxonomy_type_config&.dig(:fields) || []
    end

    private

    def generate_slug
      self.slug = name.parameterize
    end
  end
end

