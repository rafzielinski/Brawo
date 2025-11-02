module Brawo
  class RouteManager
    def self.register_routes(content_type_class)
      route_config = content_type_class.route_config
      config = content_type_class.config

      Rails.application.routes.draw do
        # Archive route
        if route_config.archive_path
          get route_config.archive_path,
              to: "brawo/content_entries#index",
              defaults: { content_type: config.slug },
              as: "#{config.slug}_archive"
        end

        # Single entry route
        if route_config.single_path_pattern
          get route_config.single_path_pattern,
              to: "brawo/content_entries#show",
              defaults: { content_type: config.slug },
              as: config.slug.singularize
        end
      end
    end
  end
end