module Brawo
  class Registry
    @content_types = {}

    class << self
      attr_reader :content_types

      def register(content_type_class)
        @content_types[content_type_class.config.slug] = content_type_class
      end

      def find(slug)
        @content_types[slug]
      end

      def all
        @content_types.values
      end
    end
  end
end