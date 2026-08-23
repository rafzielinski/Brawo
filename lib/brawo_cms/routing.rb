module BrawoCms
  module Routing
    SLUG_CONSTRAINT = /[a-z0-9]+(?:-[a-z0-9]+)*/.freeze

    module_function

    def draw_root_route(router)
      router.get "/:slug",
        to: "slugs#show",
        constraints: { slug: SLUG_CONSTRAINT },
        as: :brawo_root_content
    end

    def draw_taxonomy_routes(router, type_name:, controller: nil)
      prefix = BrawoCms.taxonomy_route_prefix(type_name)
      controller ||= prefix
      router.resources prefix.to_sym,
        controller: controller,
        only: %i[index show],
        param: :slug
    end

    def draw_content_routes(router, plural:, controller: nil)
      controller ||= plural
      BrawoCms.register_reserved_slug(plural)
      router.resources plural.to_sym,
        controller: controller,
        only: %i[index show],
        param: :slug
    end
  end
end
