require "brawo_cms/version"
require "brawo_cms/engine"

module BrawoCms
  mattr_accessor :content_types
  self.content_types = {}

  mattr_accessor :taxonomy_types
  self.taxonomy_types = {}

  class << self
    def configure
      yield self if block_given?
    end

    def register_content_type(name, klass, options = {})
      self.content_types[name.to_sym] = {
        class: klass,
        fields: options[:fields] || [],
        label: options[:label] || name.to_s.titleize,
        pages: options[:pages]
      }
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

