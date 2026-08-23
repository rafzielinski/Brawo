require "rails/generators"
require "rails/generators/migration"
require_relative "../concerns/public_scaffold"

module BrawoCms
  module Generators
    class TaxonomyTypeGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration
      include PublicScaffold

      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      class_option :skip_migration, type: :boolean, default: true, desc: "Generate migration file (usually not needed)"
      class_option :public_archive, type: :boolean, desc: "Generate public index/show controller and views"
      class_option :routes, type: :boolean, desc: "Inject public taxonomy routes using configured prefix"
      class_option :route_prefix, type: :string, desc: "Override route prefix (default: from BrawoCms.taxonomy_route_prefixes or pluralized type)"

      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      def register_route_prefix
        return unless options[:routes] || options[:public_archive]

        prefix = options[:route_prefix].presence || taxonomy_route_prefix
        BrawoCms.taxonomy_route_prefixes[taxonomy_type_name.to_sym] = prefix
        template "initializer_taxonomy_prefix.rb.tt", "config/initializers/brawo_cms_taxonomy_#{file_name}.rb"
      end

      def create_model_file
        template "model.rb.tt", "app/models/#{file_name}.rb"
      end

      def create_migration_file
        return if options[:skip_migration]

        migration_template "migration.rb.tt", "db/migrate/create_#{table_name}.rb"
      end

      def create_public_controller
        return unless options[:public_archive] || options[:routes]

        template "public_controller.rb.tt", "app/controllers/#{route_controller}_controller.rb"
      end

      def create_public_views
        return unless options[:public_archive] || options[:routes]

        template "public_index.html.erb.tt", "app/views/#{route_controller}/index.html.erb"
        template "public_show.html.erb.tt", "app/views/#{route_controller}/show.html.erb"
      end

      def inject_routes
        return unless options[:routes]

        ensure_routes_sentinel!
        prefix = options[:route_prefix].presence || taxonomy_route_prefix
        route_line = "  resources :#{prefix}, only: %i[index show], param: :slug, controller: \"#{route_controller}\""
        inject_route_line(route_line)
      end

      def show_readme
        readme "README" if behavior == :invoke
      end

      private

      def parsed_attributes
        attributes.map do |attr|
          name, type = attr.split(":")
          { name: name, type: (type || "string").to_sym }
        end
      end

      def field_definitions
        parsed_attributes.map do |attr|
          "      { name: :#{attr[:name]}, type: :#{attr[:type]}, label: '#{attr[:name].titleize}' }"
        end.join(",\n")
      end

      def route_controller
        taxonomy_route_prefix
      end
    end
  end
end
