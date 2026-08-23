module BrawoCms
  class Content < ActiveRecord::Base
    self.table_name = 'brawo_cms_contents'

    # Validations
    validates :title, presence: true
    validates :slug, presence: true, uniqueness: { scope: :type }
    validates :status, inclusion: { in: %w[draft published archived] }

    # Callbacks
    before_validation :generate_slug, if: -> { (slug.blank? && title.present?) || will_save_change_to_slug? }

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
        elsif field_type == :blocks
          define_method(field_name) do
            value = get_field(field_name)
            if value.is_a?(Array)
              value.map { |item| item.is_a?(Hash) ? item.with_indifferent_access : item }
            else
              []
            end
          end

          define_method("#{field_name}=") do |value|
            if value.is_a?(Array)
              set_field(field_name, value.map { |item| item.is_a?(Hash) ? item.stringify_keys : item })
            else
              set_field(field_name, value)
            end
          end
        elsif field_type == :repeater
          # Repeater fields return arrays of hashes
          define_method(field_name) do
            value = get_field(field_name)
            if value.is_a?(Array)
              value.map { |item| item.is_a?(Hash) ? item.with_indifferent_access : item }
            elsif value.present?
              [value].map { |item| item.is_a?(Hash) ? item.with_indifferent_access : item }
            else
              []
            end
          end

          define_method("#{field_name}=") do |value|
            if value.is_a?(Array)
              set_field(field_name, value.map { |item| item.is_a?(Hash) ? item.stringify_keys : item })
            else
              set_field(field_name, value)
            end
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

    def to_param
      slug
    end

    private

    def generate_slug
      source = slug.presence || title
      result = BrawoCms::SlugGenerator.generate(
        source,
        record_class: self.class,
        exclude_id: id
      )
      self.slug = result.slug
      @slug_adjusted = result.adjusted
    end

    def slug_adjusted?
      @slug_adjusted == true
    end
  end
end

