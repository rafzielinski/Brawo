require "brawo_cms/version"
require "brawo_cms/engine"

module BrawoCms
  mattr_accessor :content_types
  self.content_types = {}

  mattr_accessor :taxonomy_types
  self.taxonomy_types = {}

  mattr_accessor :block_types
  self.block_types = {}

  mattr_accessor :api_token

  class << self
    def configure
      yield self if block_given?
    end

    def register_content_type(name, klass, options = {})
      self.content_types[name.to_sym] = {
        class: klass,
        fields: options[:fields] || [],
        label: options[:label] || name.to_s.titleize,
        pages: options[:pages],
        page_builder: options[:page_builder] || false
      }
    end

    def register_block_type(name, options = {})
      self.block_types[name.to_sym] = {
        fields: options[:fields] || [],
        label: options[:label] || name.to_s.titleize,
        partial: options[:partial] || name.to_s
      }
    end

    def block_type(name)
      block_types[name.to_sym]
    end

    def register_taxonomy_type(name, klass, options = {})
      self.taxonomy_types[name.to_sym] = {
        class: klass,
        fields: options[:fields] || [],
        label: options[:label] || name.to_s.titleize,
        pages: options[:pages]
      }
    end
  end
end

