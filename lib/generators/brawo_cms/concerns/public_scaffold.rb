# frozen_string_literal: true

require "rails/generators"

module BrawoCms
  module Generators
    module PublicScaffold
      ROUTES_SENTINEL = "# brawo_cms:routes"

      private

      def routes_file
        "config/routes.rb"
      end

      def inject_content_routes!
        return if options[:root_path]

        route_line = "  resources :#{route_plural}, only: %i[index show], param: :slug"
        inject_route_line(route_line)
      end

      def inject_taxonomy_routes!
        prefix = BrawoCms.taxonomy_route_prefix(taxonomy_type_name)
        route_line = "  resources :#{prefix}, only: %i[index show], param: :slug, controller: \"#{route_controller}\""
        inject_route_line(route_line)
      end

      def inject_root_route!
        return unless File.exist?(routes_file)
        return if File.read(routes_file).include?("BrawoCms::Routing.draw_root_route")

        inject_into_file routes_file, before: /^end\s*$/ do
          <<~RUBY

            #{ROUTES_SENTINEL}
            BrawoCms::Routing.draw_root_route(self)
          RUBY
        end
      end

      def inject_route_line(line)
        return unless File.exist?(routes_file)
        return if File.read(routes_file).include?(line.strip)

        inject_into_file routes_file, before: ROUTES_SENTINEL do
          "#{line}\n"
        end
      end

      def ensure_routes_sentinel!
        return unless File.exist?(routes_file)
        return if File.read(routes_file).include?(ROUTES_SENTINEL)

        append_to_file routes_file do
          <<~RUBY

            #{ROUTES_SENTINEL}
          RUBY
        end
      end

      def route_plural
        file_name.pluralize
      end

      def route_controller
        route_plural
      end

      def taxonomy_type_name
        file_name.singularize
      end

      def taxonomy_route_prefix
        BrawoCms.taxonomy_route_prefix(taxonomy_type_name)
      end

      def field_erb_lines
        parsed_attributes.map do |attr|
          case attr[:type].to_sym
          when :textarea, :text
            "    <%= simple_format(@#{file_name.singularize}.#{attr[:name]}) %>"
          when :boolean, :checkbox
            "    <% if @#{file_name.singularize}.#{attr[:name]} %><span class=\"badge bg-secondary\">#{attr[:name].to_s.titleize}</span><% end %>"
          else
            "    <p><%= @#{file_name.singularize}.#{attr[:name]} %></p>"
          end
        end
      end
    end
  end
end
