# Load content type models to register them with BrawoCMS
BrawoCms.configure do |config|
  config.root_content_types = [:page]
  config.taxonomy_route_prefixes = { category: "categories" }
  config.reserved_slugs = %w[admin api rails assets packs up articles products]
end

Rails.application.config.to_prepare do
  Dir[Rails.root.join("app/models/**/*.rb")].each do |file|
    require_dependency file
  end
end
