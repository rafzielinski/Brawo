require "bundler/setup"

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

desc "Regenerate OpenAPI spec from rswag request specs"
task "openapi:generate" => "app:rswag:specs:swaggerize"

