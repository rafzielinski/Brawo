require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)
require "brawo_cms"

module Dummy
  class Application < Rails::Application
    config.load_defaults 7.1
    config.autoload_lib(ignore: %w(assets tasks))
    
    # Configure ActiveRecord to use PostgreSQL
    config.active_record.schema_format = :ruby
    
    # Asset pipeline configuration
    config.assets.enabled = true
    config.assets.version = '1.0'
  end
end

