require "brawo_cms/version"
require "brawo_cms/blocks"
require "brawo_cms/routing"
require "brawo_cms/engine"

module BrawoCms
  mattr_accessor :content_types
  self.content_types = {}

  mattr_accessor :taxonomy_types
  self.taxonomy_types = {}

  mattr_accessor :block_types
  self.block_types = {}

  mattr_accessor :api_token

  mattr_accessor :root_content_types
  self.root_content_types = [:page]

  mattr_accessor :reserved_slugs
  self.reserved_slugs = %w[admin api rails assets packs up]

  mattr_accessor :taxonomy_route_prefixes
  self.taxonomy_route_prefixes = {}

  class << self
    def configure
      yield self if block_given?
    end

    def register_content_type(name, klass, options = {})
      self.content_types[name.to_sym] = {
        class: klass,
        fields: options[:fields] || [],
        header_fields: options[:header_fields] || [],
        label: options[:label] || name.to_s.titleize,
        page_builder: options[:page_builder] || false,
        allowed_blocks: normalize_block_list(options[:allowed_blocks]),
        excluded_blocks: normalize_block_list(options[:excluded_blocks])
      }
    end

    def register_block_type(name, options = {})
      Blocks::Registry.register_from_options(name, options)
    end

    def block_type(name)
      block_types[name.to_sym]
    end

    def blocks_for(content_type_name)
      config = content_types[content_type_name.to_sym]
      return {} unless config
      return {} unless blocks_field?(config)

      filtered_block_types(config)
    end

    def content_type_uses_blocks?(content_type_name)
      config = content_types[content_type_name.to_sym]
      config.present? && blocks_field?(config)
    end

    def register_taxonomy_type(name, klass, options = {})
      self.taxonomy_types[name.to_sym] = {
        class: klass,
        fields: options[:fields] || [],
        label: options[:label] || name.to_s.titleize
      }
    end

    def root_content_type?(name)
      root_content_types.map(&:to_sym).include?(name.to_sym)
    end

    def register_reserved_slug(slug)
      reserved_slugs << slug.to_s unless reserved_slugs.include?(slug.to_s)
    end

    def taxonomy_route_prefix(type_name)
      (taxonomy_route_prefixes || {})[type_name.to_sym] || type_name.to_s.pluralize
    end

    private

    def normalize_block_list(value)
      return nil if value.blank?

      Array(value).map(&:to_sym)
    end

    def blocks_field?(config)
      (config[:fields] || []).any? { |field| field[:type].to_sym == :blocks }
    end

    def filtered_block_types(config)
      types = block_types.dup

      if config[:allowed_blocks].present?
        types = types.slice(*config[:allowed_blocks])
      end

      if config[:excluded_blocks].present?
        types = types.reject { |name, _| config[:excluded_blocks].include?(name) }
      end

      types
    end
  end
end
