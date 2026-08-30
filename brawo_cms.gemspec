require_relative "lib/brawo_cms/version"

Gem::Specification.new do |spec|
  spec.name        = "brawo_cms"
  spec.version     = BrawoCms::VERSION
  spec.authors     = ["Brawo CMS"]
  spec.email       = ["info@brawocms.com"]
  spec.homepage    = "https://github.com/brawo/brawo_cms"
  spec.summary     = "A flexible CMS engine for Rails"
  spec.description = "BrawoCMS is a flexible, developer-friendly CMS engine for Rails applications"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/brawo/brawo_cms"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib,openapi}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.0"
  spec.add_dependency "pg", "~> 1.5"
  spec.add_dependency "image_processing", "~> 1.2"
  spec.add_dependency "rodauth-rails", "~> 2.2"
  spec.add_dependency "rodauth-omniauth", "~> 0.6"
  spec.add_dependency "sequel-activerecord_connection", "~> 2.0"
  spec.add_dependency "after_commit_everywhere", "~> 1.1"
  spec.add_dependency "rotp", "~> 6.3"
  spec.add_dependency "rqrcode", "~> 3.2"
  spec.add_dependency "bcrypt", "~> 3.1"
  spec.add_dependency "tilt", "~> 2.4"
  spec.add_dependency "omniauth-google-oauth2", "~> 1.2"
  spec.add_dependency "omniauth-github", "~> 2.0"

  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "rswag-api", "~> 2.16"
  spec.add_development_dependency "rswag-specs", "~> 2.16"
  spec.add_development_dependency "rswag-ui", "~> 2.16"
end

