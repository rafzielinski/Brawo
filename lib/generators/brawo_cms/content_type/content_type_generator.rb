require "rails/generators"
require "rails/generators/migration"
require_relative "../concerns/public_scaffold"

module BrawoCms
  module Generators
    class ContentTypeGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration
      include PublicScaffold

      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      class_option :skip_migration, type: :boolean, default: true, desc: "Generate migration file (usually not needed)"
      class_option :public_controller, type: :boolean, desc: "Generate public index/show controller"
      class_option :public_views, type: :boolean, desc: "Generate public index/show views"
      class_option :routes, type: :boolean, desc: "Inject prefixed public routes (param: :slug)"
      class_option :root_path, type: :boolean, desc: "Generate root-path SlugsController setup for /:slug"
      class_option :page_builder, type: :boolean, desc: "Enable page builder with :blocks field"

      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      def apply_page_defaults
        return unless file_name == "page"

        @options = options.merge(root_path: true, page_builder: true)
      end

      def validate_options
        if options[:root_path] && options[:routes]
          raise Thor::Error, "Cannot use --root-path and --routes together. Root types use /:slug; others use /#{route_plural}/:slug."
        end
      end

      def create_model_file
        template "model.rb.tt", "app/models/#{file_name}.rb"
      end

      def create_migration_file
        return if options[:skip_migration]

        migration_template "migration.rb.tt", "db/migrate/create_#{table_name}.rb"
      end

      def create_public_controller
        return unless options[:public_controller] || options[:routes]

        template "public_controller.rb.tt", "app/controllers/#{route_controller}_controller.rb"
      end

      def create_public_views
        return unless options[:public_views] || options[:routes]

        template "public_index.html.erb.tt", "app/views/#{route_controller}/index.html.erb"
        template "public_show.html.erb.tt", "app/views/#{route_controller}/show.html.erb"
      end

      def create_root_path_scaffold
        return unless options[:root_path]

        template "slugs_controller.rb.tt", "app/controllers/slugs_controller.rb"
        template "slugs_show.html.erb.tt", "app/views/slugs/show.html.erb"
        template "slugs_partial.html.erb.tt", "app/views/slugs/_#{file_name.singularize}.html.erb"
        template "initializer_snippet.rb.tt", "config/initializers/brawo_cms_routes.rb"
      end

      def inject_routes
        ensure_routes_sentinel!

        if options[:routes]
          BrawoCms.register_reserved_slug(route_plural)
          inject_content_routes!
        end

        inject_root_route! if options[:root_path]
      end

      def show_readme
        readme "README" if behavior == :invoke
      end

      private

      def inject_content_routes!
        return if options[:root_path]

        route_line = "  resources :#{route_plural}, only: %i[index show], param: :slug"
        inject_route_line(route_line)
      end

      def parsed_attributes
        attributes.map do |attr|
          name, type = attr.split(":")
          { name: name, type: (type || "string").to_sym }
        end
      end

      def field_definitions
        fields = parsed_attributes.dup
        if options[:page_builder]
          fields << { name: "blocks", type: :blocks, label: "Page Content" }
        end

        fields.map do |attr|
          "      { name: :#{attr[:name]}, type: :#{attr[:type]}, label: '#{attr[:name].to_s.titleize}' }"
        end.join(",\n")
      end

      def page_builder_option
        options[:page_builder] ? "true" : "false"
      end
    end
  end
end
