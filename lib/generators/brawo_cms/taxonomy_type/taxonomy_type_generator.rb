require 'rails/generators'
require 'rails/generators/migration'

module BrawoCms
  module Generators
    class TaxonomyTypeGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      class_option :skip_migration, type: :boolean, default: false, desc: "Skip migration file"

      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      def create_model_file
        template "model.rb.tt", "app/models/#{file_name}.rb"
      end

      def create_migration_file
        return if options[:skip_migration]
        migration_template "migration.rb.tt", "db/migrate/create_#{table_name}.rb"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end

      private

      def parsed_attributes
        attributes.map do |attr|
          name, type = attr.split(':')
          { name: name, type: (type || 'string').to_sym }
        end
      end

      def field_definitions
        parsed_attributes.map do |attr|
          "      { name: :#{attr[:name]}, type: :#{attr[:type]}, label: '#{attr[:name].titleize}' }"
        end.join(",\n")
      end
    end
  end
end

