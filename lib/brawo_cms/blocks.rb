require "brawo_cms/blocks/definition"
require "brawo_cms/blocks/registry"
require "brawo_cms/blocks/loader"

module BrawoCms
  module Blocks
    class << self
      def define(name, root_path = nil, &block)
        root_path ||= caller_locations(1, 1).first&.path&.then { |p| File.dirname(p) }
        definition = Definition.new(name, root_path)
        definition.instance_eval(&block) if block
        Registry.register(definition)
        definition
      end

      def load!
        Loader.load_all!
      end
    end
  end
end
