module BrawoCms
  class Content < ActiveRecord::Base
    self.table_name = 'brawo_cms_contents'

    # Validations
    validates :title, presence: true
    validates :slug, presence: true, uniqueness: true
    validates :status, inclusion: { in: %w[draft published archived] }

    # Callbacks
    before_validation :generate_slug, if: -> { slug.blank? && title.present? }

    # Scopes
    scope :published, -> { where(status: 'published') }
    scope :draft, -> { where(status: 'draft') }
    scope :archived, -> { where(status: 'archived') }

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

    # Dynamic field methods based on content type definition
    def self.define_field_accessors(field_definitions)
      field_definitions.each do |field_def|
        field_name = field_def[:name]
        field_type = field_def[:type]
        
        if field_type == :reference
          # Reference fields always return arrays
          define_method(field_name) do
            value = get_field(field_name)
            Array(value).compact
          end

          define_method("#{field_name}=") do |value|
            set_field(field_name, Array(value).compact)
          end
        else
          define_method(field_name) do
            get_field(field_name)
          end

          define_method("#{field_name}=") do |value|
            set_field(field_name, value)
          end
        end
      end
    end

    # Content type metadata
    def content_type_name
      self.class.name.demodulize.underscore
    end

    def content_type_config
      BrawoCms.content_types[content_type_name.to_sym]
    end

    def field_definitions
      content_type_config&.dig(:fields) || []
    end

    private

    def generate_slug
      self.slug = title.parameterize
    end
  end
end

