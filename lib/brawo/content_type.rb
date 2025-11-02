module Brawo
  class ContentType < ActiveRecord::Base
    self.abstract_class = true

    class << self
      attr_reader :config, :field_definitions, :route_config

      def configure(&block)
        @config ||= Configuration.new
        block.call(@config) if block_given?
        @config
      end

      def routes(&block)
        @route_config ||= RouteConfiguration.new
        block.call(@route_config) if block_given?
        @route_config
      end

      def fields(&block)
        @field_definitions ||= []
        FieldDefinitionDsl.new(@field_definitions).instance_eval(&block)
        @field_definitions
      end

      def inherited(subclass)
        super
        # Trigger table generation when subclass is defined
        Brawo::TableManager.ensure_table_exists(subclass)
        Brawo::RouteManager.register_routes(subclass)
      end
    end

    # Common scopes available to all content types
    scope :published, -> { where(status: 'published').where('published_at <= ?', Time.current) }
    scope :draft, -> { where(status: 'draft') }
    scope :scheduled, -> { where(status: 'published').where('published_at > ?', Time.current) }

    # Instance methods available to all content types
    def published?
      status == 'published' && published_at.present? && published_at <= Time.current
    end

    def url
      self.class.route_config.single_path(self)
    end
  end
end